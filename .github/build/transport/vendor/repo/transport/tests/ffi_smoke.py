#!/usr/bin/env python3
"""Exercise the built C ABI against real local HTTPS/WSS, without game identity mocks.

Requires OpenSSL and websockets==15.0.1. Run after building the independent crate:
python3 transport/tests/ffi_smoke.py transport/target/debug/libtechmino_transport.so
This proves native transport boundaries, not packaged/device or account acceptance.
"""
import asyncio
import base64
import ctypes
import hashlib
import http.client
import http.server
import json
import pathlib
import select
import ssl
import subprocess
import sys
import tempfile
import threading
import time
import urllib.parse

from websockets.asyncio.server import serve
from websockets.exceptions import ConnectionClosed

HTTP_BYTES = bytes(range(256)) * 32
WS_BYTES = bytes(range(256)) * 384
CANCEL_SEEN = threading.Event()
CANCEL_STARTED = threading.Event()


class HttpFixture(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *_args):
        pass

    def do_GET(self):
        if self.path == "/delayed":
            time.sleep(0.3)
            body, status = b"independently correlated late response", 200
        elif self.path == "/bytes":
            body, status = HTTP_BYTES, 200
        elif self.path == "/redirect":
            self.send_response(302)
            self.send_header("Location", "/bytes")
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        elif self.path == "/oversize":
            self.send_response(200)
            self.send_header("Content-Length", str(2 * 1024 * 1024 + 1))
            self.end_headers()
            return
        elif self.path == "/cancel":
            self.send_response(200)
            self.send_header("Content-Length", "65536")
            self.end_headers()
            self.wfile.write(b"beginning of a bounded but unfinished response")
            self.wfile.flush()
            CANCEL_STARTED.set()
            if select.select([self.connection], [], [], 3)[0]:
                try:
                    if self.connection.recv(1) == b"":
                        CANCEL_SEEN.set()
                except (ssl.SSLError, OSError):
                    CANCEL_SEEN.set()
            self.close_connection = True
            return
        else:
            body, status = b"service unavailable", 503
        self.send_response(status)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


class Native:
    def __init__(self, library, ca=None):
        self.lib = library
        options = json.dumps({"caPem": ca} if ca else {}).encode()
        self.handle = library.tn_client_new(options, len(options))
        assert self.handle, "native TLS client did not initialize"
        self.buffer = ctypes.create_string_buffer(4 * 1024 * 1024)
        self.next_id = 1
        self.backlog = []

    def command(self, command):
        value = json.dumps(command).encode()
        return self.lib.tn_command(self.handle, value, len(value))

    def start(self, op, **values):
        ident = self.next_id
        self.next_id += 1
        assert self.command({"op": op, "id": ident, **values}) == 0
        return ident

    def poll(self):
        count = self.lib.tn_poll(self.handle, self.buffer, len(self.buffer))
        assert count >= 0, "event unexpectedly exceeded its ABI bound"
        if count:
            return json.loads(self.buffer.raw[:count])

    async def event(self, ident, kind=None, timeout=5):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            for index, event in enumerate(self.backlog):
                if event["id"] == ident and (not kind or event["kind"] == kind):
                    return self.backlog.pop(index)
            event = self.poll()
            if event:
                if event["id"] == ident and (not kind or event["kind"] == kind):
                    return event
                self.backlog.append(event)
            await asyncio.sleep(0.005)
        raise AssertionError(f"event timeout for id={ident}, kind={kind}")

    def close(self):
        self.lib.tn_client_destroy(self.handle)
        self.handle = None


def load_library(path):
    library = ctypes.CDLL(str(path))
    library.tn_client_new.argtypes = [ctypes.c_char_p, ctypes.c_size_t]
    library.tn_client_new.restype = ctypes.c_void_p
    library.tn_client_destroy.argtypes = [ctypes.c_void_p]
    library.tn_client_destroy.restype = None
    library.tn_command.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
    library.tn_command.restype = ctypes.c_int32
    library.tn_poll.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t]
    library.tn_poll.restype = ctypes.c_int32
    library.tn_callback_begin.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_size_t]
    library.tn_callback_begin.restype = ctypes.c_int32
    library.tn_random.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
    library.tn_random.restype = ctypes.c_int32
    library.tn_pkce.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_size_t]
    library.tn_pkce.restype = ctypes.c_int32
    return library


def callback_request(address, state):
    parsed = urllib.parse.urlsplit(address)
    query = urllib.parse.urlencode({"code": "single-use-callback-proof", "state": state, "issuer": "https://issuer.example"})
    connection = http.client.HTTPConnection(parsed.hostname, parsed.port, timeout=3)
    connection.request("GET", "/callback?" + query)
    response = connection.getresponse()
    status = response.status
    response.read()
    connection.close()
    return status


async def exercise(library, ca, ssl_context, http_port):
    native = Native(library, ca)
    untrusted = Native(library)
    server_failures = []
    manual_close = asyncio.Event()

    async def websocket(connection):
        try:
            path = connection.request.path
            if path == "/fragmented":
                await connection.send(["complete ", "fragmented text"])
                await connection.send([WS_BYTES[:23000], WS_BYTES[23000:70000], WS_BYTES[70000:]])
                received = await connection.recv()
                assert isinstance(received, bytes) and received == HTTP_BYTES
                await connection.send(hashlib.sha256(received).hexdigest())
                await connection.wait_closed()
            elif path == "/too-large":
                await connection.send([b"a" * 200000, b"b" * 100000])
                await connection.wait_closed()
            elif path == "/manual-close":
                await connection.wait_closed()
                assert connection.close_code == 4002
                manual_close.set()
            else:
                await connection.wait_closed()
        except ConnectionClosed:
            pass
        except Exception as error:
            server_failures.append(error)

    async with serve(websocket, "127.0.0.1", 0, ssl=ssl_context, max_size=1024 * 1024) as ws_server:
        ws_port = ws_server.sockets[0].getsockname()[1]
        https = f"https://localhost:{http_port}"
        wss = f"wss://localhost:{ws_port}"
        try:
            first = native.start("request", url=https + "/delayed")
            second = native.start("request", url=https + "/bytes")
            response = await native.event(second, "http")
            assert response["status"] == 200 and base64.b64decode(response["bodyBase64"]) == HTTP_BYTES
            assert not any(event["id"] == first for event in native.backlog), "request ownership/order was conflated"
            late = await native.event(first, "http")
            assert base64.b64decode(late["bodyBase64"]) == b"independently correlated late response"
            print("PASS HTTPS verified TLS, binary body and independent correlation")

            ident = untrusted.start("request", url=https + "/bytes")
            assert (await untrusted.event(ident))["code"] == "HTTPS_FAILED"
            ident = native.start("request", url=f"https://127.0.0.1:{http_port}/bytes")
            assert (await native.event(ident))["code"] == "HTTPS_FAILED"
            ident = untrusted.start("connect", url=wss + "/idle")
            assert (await untrusted.event(ident))["code"] == "WSS_FAILED"
            ident = native.start("connect", url=f"wss://127.0.0.1:{ws_port}/idle")
            assert (await native.event(ident))["code"] == "WSS_FAILED"
            print("PASS HTTPS/WSS reject untrusted CA and wrong hostname")

            ident = native.start("request", url=https + "/redirect")
            assert (await native.event(ident, "http"))["status"] == 302
            ident = native.start("request", url=https + "/oversize")
            assert (await native.event(ident))["code"] == "HTTP_TOO_LARGE"
            ident = native.start("request", url=https + "/unavailable")
            assert (await native.event(ident, "http"))["status"] == 503
            print("PASS HTTPS preserves status/redirect and bounds response size")

            ident = native.start("request", url=https + "/cancel")
            assert await asyncio.to_thread(CANCEL_STARTED.wait, 3)
            assert native.command({"op": "cancel", "id": ident}) == 0
            assert (await native.event(ident))["code"] == "CANCELLED"
            assert await asyncio.to_thread(CANCEL_SEEN.wait, 3), "cancellation did not release the in-flight HTTPS socket"
            print("PASS HTTPS cancellation reaches socket cleanup")

            ident = native.start("connect", url=wss + "/fragmented")
            await native.event(ident, "ws_open")
            text = await native.event(ident, "ws_message")
            assert not text["binary"] and base64.b64decode(text["dataBase64"]) == b"complete fragmented text"
            binary = await native.event(ident, "ws_message")
            assert binary["binary"] and base64.b64decode(binary["dataBase64"]) == WS_BYTES
            assert native.command({"op": "send", "id": ident, "binary": True, "dataBase64": base64.b64encode(HTTP_BYTES).decode()}) == 0
            digest = await native.event(ident, "ws_message")
            assert base64.b64decode(digest["dataBase64"]).decode() == hashlib.sha256(HTTP_BYTES).hexdigest()
            assert native.command({"op": "ping", "id": ident, "dataBase64": base64.b64encode(b"correlated-ping").decode()}) == 0
            pong = await native.event(ident, "ws_pong")
            assert base64.b64decode(pong["dataBase64"]) == b"correlated-ping"
            assert native.command({"op": "cancel", "id": ident}) == 0
            assert (await native.event(ident, "ws_close"))["code"] == 1000
            print("PASS WSS fragmented complete text/binary, outbound binary, ping and cancellation")

            ident = native.start("connect", url=wss + "/too-large")
            await native.event(ident, "ws_open")
            assert (await native.event(ident, "ws_close"))["code"] == 1009
            ident = native.start("connect", url=wss + "/manual-close")
            await native.event(ident, "ws_open")
            assert native.command({"op": "close", "id": ident, "code": 4002, "reason": "manual close proof"}) == 0
            assert (await native.event(ident, "ws_close"))["code"] == 4002
            await asyncio.wait_for(manual_close.wait(), 3)
            print("PASS WSS aggregated fragmented-message bound and manual close handshake")

            request = json.dumps({"id": native.next_id, "product": "techmino", "state": "s" * 43, "issuer": "https://issuer.example", "timeoutSeconds": 5}).encode()
            callback_id = native.next_id
            native.next_id += 1
            count = library.tn_callback_begin(native.handle, request, len(request), native.buffer, len(native.buffer))
            assert count > 0
            callback = json.loads(native.buffer.raw[:count])
            assert await asyncio.to_thread(callback_request, callback["redirectUri"], "wrong-state") == 400
            assert await asyncio.to_thread(callback_request, callback["redirectUri"], "s" * 43) == 200
            event = await native.event(callback_id, "callback")
            assert event["state"] == "s" * 43 and event["issuer"] == "https://issuer.example" and event["code"] == "single-use-callback-proof"
            print("PASS temporary loopback validates exact state/issuer before callback delivery")
            assert not server_failures, server_failures
        finally:
            native.close()
            untrusted.close()


def main():
    library = load_library(pathlib.Path(sys.argv[1]).resolve())
    with tempfile.TemporaryDirectory(prefix="product-transport-tls-") as directory:
        root = pathlib.Path(directory)
        ca_key, ca_cert, key, csr, cert = [root / name for name in ("ca.key", "ca.crt", "server.key", "server.csr", "server.crt")]
        commands = [
            ["req", "-x509", "-newkey", "rsa:2048", "-nodes", "-days", "1", "-subj", "/CN=Transport Local Test CA", "-keyout", str(ca_key), "-out", str(ca_cert), "-addext", "basicConstraints=critical,CA:TRUE"],
            ["req", "-newkey", "rsa:2048", "-nodes", "-subj", "/CN=localhost", "-keyout", str(key), "-out", str(csr), "-addext", "subjectAltName=DNS:localhost"],
            ["x509", "-req", "-in", str(csr), "-CA", str(ca_cert), "-CAkey", str(ca_key), "-CAcreateserial", "-days", "1", "-copy_extensions", "copy", "-out", str(cert)],
        ]
        for command in commands:
            subprocess.run(["openssl", *command], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert, key)
        http_server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), HttpFixture)
        http_server.daemon_threads = True
        http_server.socket = context.wrap_socket(http_server.socket, server_side=True)
        thread = threading.Thread(target=http_server.serve_forever, daemon=True)
        thread.start()
        try:
            asyncio.run(exercise(library, ca_cert.read_text(), context, http_server.server_port))
        finally:
            http_server.shutdown()
            http_server.server_close()
            thread.join(timeout=3)


if __name__ == "__main__":
    main()
