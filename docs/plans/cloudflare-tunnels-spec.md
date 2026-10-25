# Cloudflare Tunnels + Access on Orca — Spec & Implementation Plan

Status: **planned — partially superseded** (2026-10-25)
Scope: high-level goal for internet-tier exposure of orca services via
Cloudflare Tunnel, plus the concrete NixOS integration plan. Complete
handoff document for a fresh, empty-context agent.

**Supersession note (2026-10-25):** orca is moving to the eru repo and
all Cloudflare-side resources (tunnel, DNS, Access) will be Terranix in
eru — the §6 "dashboard vs OpenTofU" question and the §8
dashboard/TF decision are resolved as Terranix-in-eru. IdP: Google.
First service: dawarich. Architecture (§1, §3) and the NixOS module
design (§4, with corrections noted in the refactor plan §7.4) carry
over. See `docs/plans/eru-nixcfg-refactor.md`.

Related: `docs/network/caddy-dns-tiers.md` (DNS tier model),
`docs/CADDY.md` (current HTTPS entry point), eru `docs/plans/orca-backup-dr-plan.md` (moved with the orca host).

---

## 1. Goal

Expose selected orca services at `<service>.carrio.me` to the public
internet — the "Internet" DNS tier, which the repo treats as explicit
opt-in only — with:

1. **Zero inbound ports.** cloudflared makes outbound-only connections to
   the Cloudflare edge. The host firewall (currently TCP 22/443 only)
   stays unchanged; no port forwarding, no public IP needed.
2. **Cloudflare Access** (Zero Trust) in front of each exposed hostname —
   identity-based auth (email one-time PIN or GitHub/Google IdP) at the
   edge before traffic ever reaches the host.
3. **Same hostnames, all tiers.** The DNS tier model is preserved:
   tailnet/localnet split-horizon overrides keep answering LAN/tailnet
   clients locally through Caddy; only clients with neither add the
   public proxied CNAME → tunnel. TLS validates against the name on
   every tier, so nothing client-side changes.
4. **Per-service opt-in.** No service becomes public by accident; the
   default posture stays "not internet-accessible".

## 2. Current state (what this builds on)

- Caddy is the single HTTPS entry point per `docs/CADDY.md`: wildcard
   bind, Host-header routed, Cloudflare DNS-01 certs (LE, publicly
   trusted), agenix token. All app daemons bind loopback; the port map
   (`nixos/server/orca/ports.nix`, `oxc.ports` with duplicate-claim
   assertion) is the single source of truth for loopback ports.
- Every service file follows the exposure contract (bind loopback,
   closed ports, one Caddy vhost with `dns cloudflare` tls block).
- Internet tier: currently ZERO public records exist. This spec is the
   mechanism by which a service opts in.
- Infrastructure tooling: `/infrastructure` uses OpenTofU with a
   Cloudflare R2 backend and the `task` runner (`task nixcloud:tf:*`) —
   a natural home for the Cloudflare-side resources (see §6).

## 3. Architecture

```
                Cloudflare edge (Anycast, global)
      public DNS: <svc>.carrio.me → proxied CNAME → <tunnel-id>.cfargotunnel.com
      Access policy (identity) → only then forwarded into tunnel
                        │ outbound-only QUIC/HTTPS connections (x4)
                        ▼
                 cloudflared (orca, systemd)
                        │  http://127.0.0.1:<port>   (per-hostname ingress)
                        ▼
                 app daemons (loopback, per oxc.ports)

      LAN/tailnet clients: unchanged — split-horizon override answers the
      local IP; traffic goes straight to Caddy :443, never through Cloudflare.
```

### 3.1 Origin strategy: direct-to-app, bypassing Caddy

Two viable designs:

- **(A) tunnel → Caddy `https://127.0.0.1:443`** with per-hostname
  `originRequest.originServerName` (SNI = hostname, LE cert verifies).
  Pro: one origin rule shape. Con: TLS-verify config per rule, Caddy adds
  nothing for the public path (edge already terminates TLS).
- **(B) tunnel → each app's loopback port directly** — chosen.
  `http://127.0.0.1:<port>` per hostname, ports referenced from
  `config.oxc.ports.<service>` so the map stays authoritative. cloudflared
  connects from localhost, same as Caddy does today, so app trusted-proxy
  settings that already include 127.0.0.1 (e.g. hass `trusted_proxies`,
  trek `TRUST_PROXY=1`) keep working. `X-Forwarded-For`/`Host` are set by
  cloudflared; `CF-Access-Jwt-Assertion` etc. arrive as extra headers.

Note: services using CSRF/origin checks tied to their public URL
(paperless `PAPERLESS_URL`, trek `ALLOWED_ORIGINS`) already reference the
hostname — identical on every tier — so no changes needed.

### 3.2 Access policy model

Per exposed hostname, a **Self-hosted Access application** in Cloudflare
Zero Trust with an Include policy (email allowlist → one-time PIN, or
GitHub/Google IdP). Options per app:

| Policy action | Meaning |
| --- | --- |
| Protect | every request needs an Access session (interactive login) |
| Bypass (path-based) | selected paths skip Access — for non-interactive API clients |
| Service Auth | programmatic clients present `CF-Access-Client-Id/Secret` headers |

Non-interactive clients (mobile apps, WebDAV mounts, API keys) cannot do
interactive Access login. The standard pattern is path-scoped Bypass
rules that still leave app auth in place (every service here has its own
auth) or Service Auth headers where the client supports them.

### 3.3 Per-service exposure matrix (recommendations — final list is a decision, §8)

| Service | Public? | Access policy | Notes |
| --- | --- | --- | --- |
| dawarich | YES | Protect UI; **Bypass `/api/v1/*`** | primary use case — location upload from phones anywhere; API key is the app-layer auth on bypassed paths |
| paperless | YES | Protect UI; Bypass `/api/*` | mobile scanner apps hit the API |
| oxicloud | YES | Protect UI; **WebDAV decision** | OS WebDAV mounts can't do Access → either Bypass `/dav` paths (app's own auth protects) or keep WebDAV tailnet-only |
| stirling-pdf | YES (opt) | Protect | stateless tool, cheap to expose |
| trek | opt | Protect | own auth exists; low value publicly |
| hass | NO (default) | — | companion app needs broad API/websocket bypass; weakens Access to near-zero; keep tailnet-only unless a concrete need appears |
| jellyfin / media | **NO** | — | video through Cloudflare tunnel violates ToS §2.8 (media serving restrictions); keep tailnet-only permanently |
| pinchflat | NO | — | admin tool, tailnet-only |
| collabora | NO (default) | — | frame-ancestors locked to oxicloud origin; if oxicloud goes public and needs public editing, revisit with a dedicated policy |

## 4. NixOS implementation plan

New file `nixos/server/orca/cloudflared.nix`, imported from
`nixos/server/orca/default.nix`. Native module (`services.cloudflared`,
present in the pinned nixpkgs rev da6dc0e):

```nix
{
  config,
  lib,
  ...
}:
let
  # Hostnames opted into the internet tier. Each entry = one public
  # CNAME (managed in Cloudflare, §6) + one ingress rule + one Access
  # application. Adding a service here is the opt-in act.
  publicServices = {
    "dawarich.carrio.me" = config.oxc.ports.dawarich;
    "paperless.carrio.me" = config.oxc.ports.paperless;
    # "stirling-pdf": config.oxc.ports.stirling-pdf,
  };
in
{
  services.cloudflared = {
    enable = true;
    tunnels.orca = {
      # Tunnel ID is not secret; secret lives in the credentials file.
      id = "<tunnel-uuid>";  # provisioned once, see §6
      credentialsFile = config.age.secrets.cloudflare-tunnel-orca.path;
      ingress = lib.mapAttrs (host: port: {
        service = "http://127.0.0.1:${toString port}";
      }) publicServices // {
        # Catch-all: unknown Host → 404, do not fall through to anything
        default = { service = "http_status:404"; };
      };
      # Websockets (hass would need it if ever added) work by default;
      # noTLSVerify NOT needed — origins are plain http on loopback.
    };
  };

  age.secrets.cloudflare-tunnel-orca = {
    file = ../../../secrets/services/cloudflare/tunnel-orca.age;
    owner = "cloudflared";
    group = "cloudflared";
    mode = "400";
  };
}
```

Notes:

- **No port claims, no firewall changes.** cloudflared is purely
  outbound. Its local metrics listener (if enabled) binds loopback; claim
  it in `oxc.ports` only if we scrape it.
- The ingress table derives from `oxc.ports` — the duplicate-claim
  assertion and the tunnel stay consistent by construction.
- Module runs cloudflared as its own system user; hardening defaults are
  module-provided.
- Websocket support is default-on in cloudflared ingress (relevant for
  future hass/dawarich live updates).

## 5. Cloudflare-side resources

For each opted-in service:

1. **DNS**: proxied CNAME `<service>.carrio.me` →
   `<tunnel-id>.cfargotunnel.com` (orange cloud). Do NOT remove the
   existing tailnet/localnet split-horizon overrides — they take
   precedence for local clients; the public record is the fallback.
2. **Access application** (Zero Trust → Access → Applications →
   Self-hosted): domain `<service>.carrio.me`, policy per §3.3 matrix,
   plus path-scoped Bypass rules where the matrix calls for them.
3. **Tunnel** itself: one tunnel named `orca`, credentials JSON secret.

## 6. Management: dashboard vs OpenTofU

Two options for the Cloudflare-side pieces (tunnel, DNS records, Access
apps):

- **Dashboard/manual** — fastest, but drifts silently and is invisible to
  the repo.
- **OpenTofU** in `/infrastructure` with the `cloudflare` provider —
  RECOMMENDED: `cloudflare_tunnel` (locally-managed secret → goes into
  agenix once), `cloudflare_record` per service, `cloudflare_access_*
  for applications/policies. The repo already runs OpenTofU with an R2
  state backend and `task nixcloud:tf:*` targets; add a
  `cloudflare-tunnel` stack alongside. Caveat: tunnel secret then exists
  in TF state (R2 backend, private) AND agenix (host) — acceptable,
  document it.
- The NixOS `certificateFile` path (fully declarative tunnel route
  management from the host) is deliberately not used: managing routes in
  TF keeps all Cloudflare state in one place.

## 7. Implementation phases

1. **Tunnel + one service (dawarich).** Provision tunnel (TF or
   dashboard), credentials → agenix (`secrets/services/cloudflare/` +
   `secrets/secrets.nix` entry with `systems.orca.host` recipient +
   age-matrix), `cloudflared.nix` with dawarich only, public CNAME,
   Access app (Protect + `/api/v1/*` bypass).
   Verify: `systemctl status cloudflared-tunnel-orca`; from an external
   network (LTE, no tailnet): `https://dawarich.carrio.me` shows Access
   login → UI loads; mobile app posts points over `/api/v1/*` without
   Access prompt; from LAN, DNS still answers the local IP (dig
   confirms, no Cloudflare hop).
2. **Remaining YES services** (paperless, then opt-ins) one at a time,
   each: ingress entry + CNAME + Access app. Verify per service: auth
   flow + a real client (paperless mobile app against `/api/`).
3. **OpenTofU stack** (if chosen): import/replace manually-created
   resources; `task` targets documented.
4. **Docs**: update `docs/network/caddy-dns-tiers.md` internet-tier row
   with the tunnel mechanism + per-service opt-in list; note in
   `docs/CADDY.md` that the public tier bypasses Caddy by design.

## 8. Decisions needed

1. Final exposure list (§3.3 recommendations: dawarich, paperless,
   oxicloud core; stirling/trek optional).
2. OxiCloud WebDAV: bypass `/dav` publicly or tailnet-only?
3. IdP for Access: email one-time PIN (zero deps) vs GitHub/Google.
4. TF vs dashboard for Cloudflare-side management.
5. Confirm jellyfin stays off the tunnel permanently (ToS).

## 9. Risks / notes

- **Public attack surface**: every exposed service is now reachable by
  anyone on the internet; Access is the gate. Keep bypass paths minimal
  and rely on app auth there. Cloudflare WAF/managed rules available in
  front if wanted later.
- **cloudflared is a SPOF for the public tier only** — LAN/tailnet paths
  never depend on it (split-horizon overrides answer first).
- **Cloudflare ToS**: no media streaming through the tunnel (jellyfin
  excluded for this reason). Large file uploads/downloads (oxicloud)
  are file transfer, generally fine, but bandwidth-heavy use should go
  via tailnet.
- **Secrets**: tunnel credentials JSON is host-specific, not an account
  token — leaking it lets an attacker register a connection to YOUR
  tunnel only if they can also intercept... in fact a leaked credentials
  file alone IS enough to serve a fake origin; treat as sensitive
  (agenix, 400, cloudflared-owned) and rotate via TF re-provision if
  suspected.
- **Dawarich mobile app + Access**: verify the app sends its API key on
  the bypassed path pattern before relying on it (phase 1 includes this
  check); if the app hits non-`/api/v1` paths, widen the bypass
  deliberately and note it.
