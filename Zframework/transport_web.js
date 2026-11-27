/* Browser TLS, HTTP cookies and WebSocket framing stay browser-owned. */
(function (global) {
    "use strict";
    if (global.TechminoTransport) return;
    const HTTP_LIMIT = 2 * 1024 * 1024, WS_LIMIT = 256 * 1024, EVENT_LIMIT = 4 * 1024 * 1024;
    const clients = new Map();
    let nextClient = 1;
    const encoder = new TextEncoder();
    const failResult = (code, message) => ({ ok: false, error: { code, message } });
    const success = result => ({ ok: true, result });
    function decode(value, limit) {
        if (typeof value !== "string" || value.length > Math.ceil(limit / 3) * 4) throw new Error("RESOURCE_LIMIT");
        const raw = atob(value), data = new Uint8Array(raw.length);
        if (data.length > limit) throw new Error("RESOURCE_LIMIT");
        for (let i = 0; i < raw.length; i++) data[i] = raw.charCodeAt(i);
        return data;
    }
    function encode(data) {
        let result = "";
        for (let i = 0; i < data.length; i += 8192) result += String.fromCharCode.apply(null, data.subarray(i, i + 8192));
        return btoa(result);
    }
    function verifiedUrl(value, scheme) {
        if (typeof value !== "string" || value.length > 4096) throw new Error("INVALID_ARGUMENT");
        const url = new URL(value);
        if (url.protocol !== scheme + ":" || url.username || url.password || url.hash) throw new Error("INVALID_ARGUMENT");
        return url;
    }
    function issuerUrl(value) {
        const url = new URL(value);
        if (!(url.protocol === "https:" || (url.protocol === "http:" && ["localhost", "127.0.0.1", "[::1]"].includes(url.hostname))) || url.username || url.password || url.search || url.hash) throw new Error("INVALID_CALLBACK");
        return url;
    }
    function headerList(values, websocket) {
        values = values || {};
        const entries = Object.entries(values);
        if (entries.length > 32 || entries.reduce((n, pair) => n + pair[0].length + String(pair[1]).length, 0) > 16384) throw new Error("RESOURCE_LIMIT");
        if (websocket && entries.length) throw new Error("BROWSER_WEBSOCKET_HEADERS_UNSUPPORTED");
        for (const [key, value] of entries) {
            if (typeof value !== "string" || /^(cookie|host|content-length|connection|upgrade)$/i.test(key) || /^sec-websocket-/i.test(key)) throw new Error("INVALID_ARGUMENT");
        }
        return new Headers(values);
    }
    function error(client, id, code, message) { client.push({ kind: "error", id, code, message }); }
    class Client {
        constructor() { this.operations = new Map(); this.queue = []; this.bytes = 0; this.lastId = 0; this.closed = false; this.fatal = null; }
        admit(id, type) {
            if (this.closed) throw new Error("TRANSPORT_CLOSED");
            if (!Number.isSafeInteger(id) || id <= this.lastId) throw new Error("REQUEST_ID_REUSED");
            const limit = { request: 16, socket: 4, callback: 2 }[type];
            if (this.operations.size >= 24 || [...this.operations.values()].filter(op => op.type === type).length >= limit) throw new Error("RESOURCE_LIMIT");
            this.lastId = id;
        }
        push(value) {
            if (this.closed) return false;
            const json = JSON.stringify(value), bytes = encoder.encode(json).length;
            if (this.queue.length >= 128 || this.bytes + bytes > EVENT_LIMIT) {
                this.fatal = { kind: "error", id: 0, code: "TRANSPORT_BACKPRESSURE", message: "Transport event queue exceeded its bound; all connections were closed." };
                this.destroy();
                return false;
            }
            this.queue.push({ value, bytes }); this.bytes += bytes; return true;
        }
        poll() {
            const event = this.queue.shift();
            if (event) { this.bytes -= event.bytes; return event.value; }
            if (this.fatal) { const fatal = this.fatal; this.fatal = null; return fatal; }
            return null;
        }
        destroy() {
            this.closed = true;
            for (const operation of this.operations.values()) {
                if (operation.controller) operation.controller.abort();
                if (operation.socket && operation.socket.readyState < 2) operation.socket.close(1000, "Transport closed");
                if (operation.popup && !operation.popup.closed) operation.popup.close();
                clearTimeout(operation.timer);
            }
            this.operations.clear();
        }
        request(command) {
            const url = verifiedUrl(command.url, "https");
            const headers = headerList(command.headers, false);
            const method = command.method || "GET", timeout = command.timeoutMs || 20000;
            if (!["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"].includes(method) || timeout < 100 || timeout > 120000) throw new Error("INVALID_ARGUMENT");
            const body = decode(command.bodyBase64 || "", HTTP_LIMIT);
            if ((method === "GET" || method === "HEAD") && body.length) throw new Error("INVALID_ARGUMENT");
            if (command.credentials && !["omit", "include"].includes(command.credentials)) throw new Error("INVALID_ARGUMENT");
            this.admit(command.id, "request");
            const operation = { type: "request", controller: new AbortController(), cancelled: false, timedOut: false };
            operation.timer = setTimeout(() => { operation.timedOut = true; operation.controller.abort(); }, timeout);
            this.operations.set(command.id, operation);
            (async () => {
                try {
                    const options = { method, headers, credentials: command.credentials || "omit", signal: operation.controller.signal, redirect: "error", cache: "no-store" };
                    if (body.length) options.body = body;
                    const response = await fetch(url.href, options);
                    const length = Number(response.headers.get("content-length"));
                    if (length > HTTP_LIMIT) { operation.controller.abort(); throw new Error("HTTP_TOO_LARGE"); }
                    const chunks = []; let total = 0;
                    if (response.body) {
                        const reader = response.body.getReader();
                        try {
                            while (true) {
                                const chunk = await reader.read(); if (chunk.done) break;
                                total += chunk.value.length;
                                if (total > HTTP_LIMIT) { await reader.cancel(); throw new Error("HTTP_TOO_LARGE"); }
                                chunks.push(chunk.value);
                            }
                        } finally { reader.releaseLock(); }
                    }
                    const bytes = new Uint8Array(total); let offset = 0;
                    for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
                    const responseHeaders = {}; response.headers.forEach((value, key) => { responseHeaders[key] = value; });
                    this.push({ kind: "http", id: command.id, status: response.status, headers: responseHeaders, bodyBase64: encode(bytes) });
                } catch (exception) {
                    const code = operation.cancelled ? "CANCELLED" : operation.timedOut ? "HTTP_TIMEOUT" : exception.message === "HTTP_TOO_LARGE" ? "HTTP_TOO_LARGE" : "HTTPS_FAILED";
                    error(this, command.id, code, "Verified HTTPS request failed, was cancelled, or exceeded its bounds.");
                } finally { clearTimeout(operation.timer); this.operations.delete(command.id); }
            })();
        }
        connect(command) {
            const url = verifiedUrl(command.url, "wss");
            headerList(command.headers, true);
            const timeout = command.timeoutMs || 20000;
            if (timeout < 100 || timeout > 120000) throw new Error("INVALID_ARGUMENT");
            this.admit(command.id, "socket");
            const socket = new WebSocket(url.href); socket.binaryType = "arraybuffer";
            const operation = { type: "socket", socket, pendingMessages: 0, timedOut: false };
            this.operations.set(command.id, operation);
            operation.timer = setTimeout(() => { operation.timedOut = true; socket.close(); }, timeout);
            socket.onopen = () => { clearTimeout(operation.timer); this.push({ kind: "ws_open", id: command.id }); };
            socket.onmessage = event => {
                const binary = typeof event.data !== "string";
                const bytes = binary ? new Uint8Array(event.data) : encoder.encode(event.data);
                if (bytes.length > WS_LIMIT) { socket.close(4009, "Message exceeded its limit"); return; }
                this.push({ kind: "ws_message", id: command.id, binary, dataBase64: encode(bytes) });
            };
            socket.onerror = () => error(this, command.id, "WSS_FAILED", "Verified TLS/WebSocket connection failed.");
            socket.onclose = event => {
                clearTimeout(operation.timer); this.operations.delete(command.id);
                this.push({ kind: "ws_close", id: command.id, code: event.code, reason: operation.timedOut ? "WebSocket handshake timed out" : event.reason });
            };
        }
        callback(command) {
            if (!["techmino", "techminoGalaxy"].includes(command.product) || !/^[A-Za-z0-9._~-]{32,128}$/.test(command.state)) throw new Error("INVALID_CALLBACK");
            issuerUrl(command.issuer);
            const timeout = command.timeoutSeconds || 180;
            if (timeout < 1 || timeout > 180) throw new Error("INVALID_CALLBACK");
            const redirect = new URL(command.redirectUri || location.href); redirect.search = ""; redirect.hash = "";
            if (redirect.origin !== location.origin || redirect.username || redirect.password || !["https:", "http:"].includes(redirect.protocol)) throw new Error("INVALID_CALLBACK");
            this.admit(command.id, "callback");
            const popup = global.open("about:blank", "product_authorization_" + command.id);
            if (!popup) throw new Error("POPUP_BLOCKED");
            const operation = { type: "callback", popup, redirectUri: redirect.href, state: command.state, issuer: command.issuer };
            operation.timer = setTimeout(() => { popup.close(); this.operations.delete(command.id); error(this, command.id, "CALLBACK_EXPIRED", "Authorization callback expired."); }, timeout * 1000);
            this.operations.set(command.id, operation);
            return { id: command.id, redirectUri: redirect.href };
        }
    }
    global.addEventListener("message", event => {
        if (event.origin !== location.origin || !event.data || event.data.kind !== "product-authorization-callback" || typeof event.data.url !== "string" || event.data.url.length > 8192) return;
        for (const client of clients.values()) for (const [id, operation] of client.operations) {
            if (operation.type !== "callback" || event.source !== operation.popup) continue;
            let url;
            try { url = new URL(event.data.url); } catch (_) { continue; }
            const values = new Map(); let valid = !url.hash;
            for (const [key, value] of url.searchParams) {
                if (!["code", "error", "state", "issuer"].includes(key) || values.has(key) || value.length > 4096) { valid = false; break; }
                values.set(key, value);
            }
            url.search = "";
            const code = values.get("code"), denied = values.get("error");
            if (!valid || url.href !== operation.redirectUri || values.get("state") !== operation.state || values.get("issuer") !== operation.issuer || Boolean(code) === Boolean(denied) || (code || denied).length > 2048) continue;
            clearTimeout(operation.timer); client.operations.delete(id);
            operation.popup.close();
            const result = { kind: "callback", id, state: operation.state, issuer: operation.issuer };
            if (code) result.code = code; else result.error = denied;
            client.push(result);
        }
    });
    const callbackQuery = new URLSearchParams(location.search);
    if (global.opener && callbackQuery.has("state") && callbackQuery.has("issuer") && (callbackQuery.has("code") !== callbackQuery.has("error"))) {
        global.opener.postMessage({ kind: "product-authorization-callback", url: location.href }, location.origin);
        history.replaceState(null, "", location.pathname);
        global.close();
    }
    function dispatch(command) {
        if (command.call === "create") {
            if (clients.size >= 4) throw new Error("RESOURCE_LIMIT");
            const id = nextClient++; clients.set(id, new Client()); return id;
        }
        if (command.call === "random") {
            if (!Number.isInteger(command.count) || command.count < 1 || command.count > 4096) throw new Error("INVALID_ARGUMENT");
            return encode(global.crypto.getRandomValues(new Uint8Array(command.count)));
        }
        const client = clients.get(command.client); if (!client) throw new Error("TRANSPORT_CLOSED");
        if (command.call === "poll") return client.poll();
        if (command.call === "destroy") { client.destroy(); clients.delete(command.client); return true; }
        if (command.op === "request") { client.request(command); return true; }
        if (command.op === "connect") { client.connect(command); return true; }
        if (command.op === "callback_begin") return client.callback(command);
        const operation = client.operations.get(command.id);
        if (!operation) throw new Error("UNKNOWN_OPERATION");
        if (command.op === "open_authorization") {
            const url = issuerUrl(command.authorizationOrigin || operation.issuer), target = new URL(command.url);
            if (target.origin !== url.origin || target.username || target.password || !operation.popup || operation.popup.closed) throw new Error("INVALID_AUTHORIZATION_URL");
            operation.popup.location.href = target.href; return true;
        }
        if (command.op === "cancel") {
            if (operation.controller) { operation.cancelled = true; operation.controller.abort(); }
            if (operation.socket) operation.socket.close(1000, "Cancelled");
            if (operation.popup) { clearTimeout(operation.timer); operation.popup.close(); client.operations.delete(command.id); error(client, command.id, "CALLBACK_CANCELLED", "Authorization callback was cancelled."); }
            return true;
        }
        if (operation.type !== "socket") throw new Error("UNKNOWN_OPERATION");
        if (command.op === "send") {
            if (operation.socket.readyState !== WebSocket.OPEN) throw new Error("SOCKET_NOT_OPEN");
            const data = decode(command.dataBase64, WS_LIMIT);
            if (operation.socket.bufferedAmount === 0) operation.pendingMessages = 0;
            if (operation.socket.bufferedAmount + data.length > WS_LIMIT || operation.pendingMessages >= 128) throw new Error("RESOURCE_LIMIT");
            operation.pendingMessages++;
            operation.socket.send(command.binary ? data : new TextDecoder("utf-8", { fatal: true }).decode(data)); return true;
        }
        if (command.op === "ping") throw new Error("BROWSER_MANAGED_PING");
        if (command.op === "close") {
            const code = command.code || 1000, reason = command.reason || "";
            if (!(code === 1000 || (code >= 3000 && code <= 4999)) || encoder.encode(reason).length > 123) throw new Error("INVALID_ARGUMENT");
            operation.socket.close(code, reason); return true;
        }
        throw new Error("INVALID_ARGUMENT");
    }
    global.TechminoTransport = {
        bridge(command, saveDirectory) {
            let result;
            try { result = success(dispatch(command)); }
            catch (exception) {
                const allowed = ["RESOURCE_LIMIT", "INVALID_ARGUMENT", "INVALID_CALLBACK", "POPUP_BLOCKED", "TRANSPORT_CLOSED", "REQUEST_ID_REUSED", "UNKNOWN_OPERATION", "SOCKET_NOT_OPEN", "BROWSER_WEBSOCKET_HEADERS_UNSUPPORTED", "BROWSER_MANAGED_PING", "INVALID_AUTHORIZATION_URL"];
                result = failResult(allowed.includes(exception.message) ? exception.message : "TRANSPORT_FAILED", "Transport operation was rejected; no credentials were persisted.");
            }
            global.FS.writeFile(saveDirectory + "/__transport_reply", JSON.stringify(result));
        }
    };
})(window);
