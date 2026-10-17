# Caddy

Caddy is the single HTTPS entry point on every host that exposes services.
One instance per host, wildcard-bound (LAN + tailnet + any other interface),
Host-header routed. This document covers certificate provisioning, the
reverse proxy contract, and authorization layers. The DNS tier model that
makes the names resolve is defined in
[`docs/network/caddy-dns-tiers.md`](network/caddy-dns-tiers.md) — read that
first.

Reference implementation: `nixos/server/orca/` (`media-server.nix`,
`pinchflat.nix`, `hass.nix`).

## ACME / certificates

Certificates are issued by Caddy through **Cloudflare DNS-01** challenges:

- `carrio.me` is a real public Cloudflare zone → certificates are publicly
  trusted. No private CA, nothing to install on clients.
- DNS-01 requires **no inbound ports** and works on hosts with no port
  forwarding or public reachability.
- One certificate per vhost, provisioned at Caddy startup.

### Plugin

The DNS provider is a Caddy plugin, pinned explicitly (vendor hash must
match the plugin version):

```nix
services.caddy = {
  enable = true;
  package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
  };
};
```

Version pinning matters: `v0.2.1` predates Cloudflare's new token formats
(`cfut_` user / `cfat_` account tokens) and rejects them at config load with
`API token ... appears invalid`. `v0.2.4` accepts both legacy and new
formats. When certificate provisioning fails with a token-format complaint,
check the plugin pin first.

To recompute the hash after a version bump (works from darwin, no linux
builder needed):

```
nix build --impure --expr 'let pkgs = import <nixpkgs> {}; in
  pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  }'
# error message contains: got: sha256-...
```

### API token

The Cloudflare token is an agenix secret, injected into the Caddy systemd
unit — never in the Nix store:

- Secret: `secrets/services/acme/cloudflare.age`, recipients include the
  host's SSH host key (see `secrets/secrets.nix`).
- Definition + wiring (from `nixos/server/orca/media-server.nix`):

```nix
age.secrets.cloudflare-dns-verification = {
  file = ../../../secrets/services/acme/cloudflare.age;
  owner = "root";
  group = "root";
  mode = "400";
};

systemd.services.caddy = {
  serviceConfig.EnvironmentFile =
    config.age.secrets.cloudflare-dns-verification.path;
};
```

No `after`/`wants` against `agenix-*` units: the pinned agenix revision
installs secrets via activation scripts (`agenixInstall`), which complete
before regular services start. Older per-secret `agenix-<name>.service`
units no longer exist — do not reference them.

Token requirements: Cloudflare API token with `Zone → Zone → Read` and
`Zone → DNS → Edit` on the `carrio.me` zone. User Access Tokens (`cfut_...`)
work with plugin `v0.2.4+`.

## Vhost pattern

Every exposed service gets one vhost, same shape everywhere:

```nix
services.caddy.virtualHosts."<service>.carrio.me".extraConfig = ''
  tls {
    dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
  }
  reverse_proxy 127.0.0.1:<port>
'';
```

The daemon binds `127.0.0.1`, its port stays closed in the firewall, and
Caddy is the only thing listening publicly (443 TCP + UDP for HTTP/3, plus
22 for SSH). Websockets pass through `reverse_proxy` natively — no extra
config for Home Assistant, Pinchflat, or Z2M.

## Authorization

Some services have no native authentication (e.g. Zigbee2MQTT's frontend
assumes a trusted network). Three enforcement layers, combinable. Pick per
vhost.

### 1. Network gate — tailnet-only by source IP

Tailscale traffic always arrives from the CGNAT range `100.64.0.0/10`.
Matching on it restricts a vhost to the tailnet tier regardless of which IP
the client dialed:

```nix
services.caddy.virtualHosts."z2m.carrio.me".extraConfig = ''
  tls {
    dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
  }
  @tailnet remote_ip 100.64.0.0/10
  handle @tailnet {
    reverse_proxy 127.0.0.1:9807
  }
  respond "tailnet only" 403
'';
```

- `z2m.carrio.me` → 100.x: request sources from a tailnet IP → passes.
- Same name → 192.168.1.x: source is a LAN IP → 403.
- Identity = tailnet membership. Refine who can even see the host via the
  Tailscale ACL file: [`docs/network/tailscale-acl.jsonc`](network/tailscale-acl.jsonc).
- Zero extra dependencies. Good default for LAN-untrusted services.

Notes: Caddy receives connections directly (no upstream proxy), so
`remote_ip` sees true client addresses. If a host ever sits behind another
proxy, switch to `client_ip` and set `trusted_proxies`.

### 2. Caddy `basic_auth` — per-user, works on every tier

Standard HTTP basic auth at the proxy, independent of network path:

```
basic_auth {
  <user> $2a$14$<bcrypt hash>
}
```

Generate the hash with:

```
caddy hash-password --plaintext '<password>'
```

Credentials live in the Caddyfile (bcrypt hashes, not plaintext). Combines
with the network gate: put `basic_auth` inside the `handle @tailnet` block
to demand both tailnet provenance and a password. Prefer putting secrets in
agenix and using `basic_auth` with a placeholder-substituted snippet if the
credentials are sensitive enough to rotate — but bcrypt-in-config is
generally acceptable for inner-layer auth.

### 3. Tailscale identity — `caddy-tailscale` plugin

True per-identity auth: Caddy asks local `tailscaled` (whois) to resolve the
incoming tailnet connection to a user/device and enforces policies on it.

Plugin:

```nix
package = pkgs.caddy.withPlugins {
  plugins = [
    "github.com/caddy-dns/cloudflare@v0.2.4"
    "github.com/tailscale/caddy-tailscale@<pinned>"
  ];
  hash = "sha256-<recomputed>";
};
```

Vhost side, `tailscale` directive performs the enforcement (rejects any
request without a valid Tailscale identity — LAN-tier requests fail closed):

```
tailscale {
  auth_url https://<optional interactive login fallback>
}
```

Host requirements beyond the vhost:

- `services.tailscale.enable = true` (already on orca).
- Caddy needs read access to the tailscaled socket
  (`/run/tailscale/tailscaled.sock`) — grant via a shared group or
  `systemd.services.caddy.supplementaryGroups`.
- Requests over the LAN tier cannot present a Tailscale identity and are
  rejected. Only adopt this for vhosts that should be tailnet-exclusive
  with per-user control.

Use when multiple services need named-user enforcement and ACLs alone are
too coarse. Not currently deployed anywhere in this repo — this section is
the recipe for when it's first needed.

## Choosing a layer

| Need | Use |
| --- | --- |
| Service fine for whole tailnet, untrusted on LAN | 1 (network gate) |
| Small user set, any network path | 2 (`basic_auth`) |
| Named tailnet users/devices, strict per-user policy | 3 (caddy-tailscale) |
| Defense in depth for unauthenticated UIs | 1 + 2 combined |

Default posture stays: not internet-accessible, no public DNS record
(see `docs/network/caddy-dns-tiers.md`).
