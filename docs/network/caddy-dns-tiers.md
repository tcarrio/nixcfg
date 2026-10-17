# Service Exposure Pattern: DNS Tiers + Verified HTTPS via Caddy

Caddy operational details (ACME setup, plugin pinning, authorization
layers): [`../CADDY.md`](../CADDY.md).

Intended approach for reaching services on hosts that move on and off the
tailnet. One hostname per service, verified (publicly trusted) certificates,
HTTPS-only, reverse-proxied through Caddy on every network the host is
reachable from.

Reference implementation: `nixos/server/orca/` (`media-server.nix`,
`pinchflat.nix`, `hass.nix`).

## DNS tiers

Each `<service>.carrio.me` name can exist in up to three Cloudflare views:

| Tier | Record | Answers | Use |
| --- | --- | --- | --- |
| Tailnet | split-horizon override | host's Tailscale IP (`100.x.y.z`) | host off LAN, on tailnet |
| Localnet | split-horizon override | host's LAN IP (`192.168.1.x`) | host on home LAN |
| Internet | public record | public/reachable IP | explicit opt-in only |

The hostname never changes between tiers. Only the DNS answer changes.
Because TLS is validated against the name (not the IP), the same certificate
and the same Host header work on every tier. A host that leaves the LAN and
joins the tailnet keeps working: flip the DNS override to the Tailscale IP
(or pre-provision both tiers) and clients reconnect transparently.

## Certificate provisioning

Certificates are issued by Caddy via Cloudflare DNS-01 challenges:

- `carrio.me` is a real public Cloudflare zone, so certificates are publicly
  trusted (no self-signed CA, no client trust stores to manage).
- DNS-01 needs no inbound ports. Works on hosts with zero port forwarding.
- The Cloudflare API token is provisioned through agenix
  (`secrets/services/acme/cloudflare.age`) and injected into the Caddy
  systemd unit via `EnvironmentFile` — see `nixos/server/orca/media-server.nix`.
- Each vhost requests its own certificate with a `tls { dns cloudflare ... }`
  block.

## Host configuration contract

Every exposed service on a host follows the same shape:

1. **Bind loopback.** The daemon listens on `127.0.0.1` only.
2. **Closed service ports.** `openFirewall = false` (or equivalent). The
   service port must never appear in `networking.firewall.allowedTCPPorts`.
3. **Caddy vhost.** One `services.caddy.virtualHosts."<service>.carrio.me"`
   entry with the Cloudflare DNS-01 `tls` block and
   `reverse_proxy 127.0.0.1:<port>`.
4. **Firewall allows only Caddy + admin.** TCP `443` (plus UDP `443` for
   HTTP/3) and `22` for SSH. Nothing else.

Result: services are reachable only over HTTPS, only through Caddy, on
whatever interface the client can reach (LAN address or Tailscale address —
Caddy binds wildcard). Routing is Host-header based; the IP underneath is
irrelevant.

Websockets pass through Caddy's `reverse_proxy` natively; no extra config.

## Exposure defaults

**Default: NOT internet-accessible.** Internal-only services simply get no
public DNS record. The split-horizon overrides answer on tailnet/localnet
views; the public view returns NXDOMAIN. No record, no route, no exposure.

Making a service internet-reachable is an explicit, deliberate addition of a
public record (plus whatever ingress/firewall change that implies). Do not
add public records reflexively. Some services (e.g. Home Assistant, Zigbee2MQTT)
must never be internet-tier.

## Adding a new service

```nix
# 1. Daemon on localhost, port closed
services.<daemon> = {
  enable = true;
  openFirewall = false;          # or omit if default-false
  # bind/host options = 127.0.0.1 where the module supports it
};

# 2. Caddy vhost with DNS-01
services.caddy.virtualHosts."<service>.carrio.me".extraConfig = ''
  tls {
    dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
  }
  reverse_proxy 127.0.0.1:<port>
'';
```

Then add split-horizon DNS overrides for `<service>.carrio.me` on the
tailnet and/or localnet views pointing at the host's current address.

## Caveats

- Internet tier only works when something can actually reach the host
  (port forward, cloud host, or relay). Verified certs do not imply
  reachability.
- Cloudflare token must keep `Zone:DNS:Edit` on `carrio.me`.
- Names with a public record are discoverable via certificate transparency
  logs even if the service itself is unreachable. Another reason the default
  is no public record.
