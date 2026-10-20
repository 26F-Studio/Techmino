#ifndef TECHMINO_TRANSPORT_H
#define TECHMINO_TRANSPORT_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

/* Every handle is caller-owned, must not be destroyed while another C call uses it,
 * and must be destroyed exactly once. Workers never call into Lua.
 * Options JSON: {"caPem":"optional additional trusted CA PEM"}; never disables TLS.
 * HTTP/WSS URL schemes are strictly https/wss, cookies are not sent natively.
 * Commands use monotonically increasing numeric IDs (1..2^53-1), shared by HTTP,
 * socket and callback admission. Request/send payloads use standard base64.
 * Command result: 0 accepted; -1 invalid; -2 closed; -3 bounded resource limit;
 * -4 reused/non-monotonic ID; -5 no matching live operation.
 * Poll returns exact JSON byte length, 0 empty, or negative required capacity;
 * insufficient poll capacity never consumes an event. INT32_MIN means invalid.
 * Incoming: <=128 events/4 MiB, HTTP body<=2 MiB, WS complete message<=256 KiB.
 * Outgoing socket queue: <=128 messages/256 KiB; slow consumers close, no silent
 * mandatory-message drops. HTTPS redirects are returned, never auto-followed.
 * callback_begin/secret require capacity>=16384 BEFORE any side effect; output
 * is JSON and contains errors. C ABI does not retain borrowed input buffers.
 */
void *tn_client_new(const uint8_t *json, size_t len);
void tn_client_destroy(void *client);
int32_t tn_command(void *client, const uint8_t *json, size_t len);
int32_t tn_poll(void *client, uint8_t *out, size_t capacity);
int32_t tn_callback_begin(void *client, const uint8_t *json, size_t len, uint8_t *out, size_t capacity);
int32_t tn_secret(const uint8_t *json, size_t len, uint8_t *out, size_t capacity);
int32_t tn_random(uint8_t *out, size_t count);
int32_t tn_pkce(const uint8_t *verifier, size_t len, uint8_t *out, size_t capacity);
void tn_mobile_callback(const uint8_t *url, size_t len);
#ifdef __cplusplus
}
#endif
#endif
