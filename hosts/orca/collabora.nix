{
  config,
  ...
}:
let
  external_domain = "office.carrio.me";
  oxicloud_domain = "oxicloud.carrio.me";
  # Claimed centrally in ports.nix; the oxc.ports assertion blocks
  # collisions with other services at eval time.
  port = config.oxc.ports.collabora;
  # Loopback publish of the OxiCloud container (see oxicloud.nix).
  oxicloud_internal = "http://127.0.0.1:${toString config.oxc.ports.oxicloud}";
in
{
  # Native NixOS Collabora Online (CODE) — the WOPI editor OxiCloud's own
  # docker-compose.wopi.yml targets. coolwsd serves plain HTTP on loopback;
  # TLS terminates at Caddy. The editor iframe is embedded by the OxiCloud
  # web app, so frame_ancestors must allow its origin.
  services.collabora-online = {
    enable = true;
    inherit port;

    # WOPI-host allowlist. OxiCloud hands coolwsd WOPI endpoint URLs on the
    # internal loopback address (OXICLOUD_WOPI_BASE_URL in oxicloud.nix);
    # the public name is listed as an alias of the same host.
    aliasGroups = [
      {
        host = oxicloud_internal;
        aliases = [ "https://${oxicloud_domain}" ];
      }
    ];

    settings = {
      ssl = {
        enable = false;
        termination = true;
      };
      net.frame_ancestors = "https://${oxicloud_domain}";
    };
  };

  # Shares the Caddy + Cloudflare DNS-01 setup from media-server.nix, where
  # the CLOUDFLARE_DNS_API_TOKEN EnvironmentFile is wired into the service.
  # Caddy passes the Host header through, so coolwsd's WOPI discovery
  # advertises office.carrio.me action URLs (reachable from browsers).
  services.caddy.virtualHosts."${external_domain}".extraConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
