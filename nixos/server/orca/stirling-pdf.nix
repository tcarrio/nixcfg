{
  config,
  ...
}:
let
  external_domain = "pdfs.carrio.me";
  # Claimed centrally in ports.nix; the oxc.ports assertion blocks
  # collisions with other services at eval time.
  port = config.oxc.ports.stirling-pdf;
in
{
  # Native NixOS module (nixpkgs 26.05). State lives in /var/lib/stirling-pdf.
  # The module opens no firewall ports and runs with systemd hardening +
  # DynamicUser. SERVER_ADDR pins the listener to loopback per the host
  # configuration contract; upstream defaults to all interfaces.
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_ADDR = "127.0.0.1";
      SERVER_PORT = port;
    };
  };

  # Shares the Caddy + Cloudflare DNS-01 setup from media-server.nix, where
  # the CLOUDFLARE_DNS_API_TOKEN EnvironmentFile is wired into the service.
  services.caddy.virtualHosts."${external_domain}".extraConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
