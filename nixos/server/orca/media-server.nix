{
  config,
  pkgs,
  ...
}:
let
  external_domain = "media.carrio.me";
  dataDir = "/data/media";
in
{
  imports = [
    # Definition for a common group for media services like Plex and Jellyfin
    # This is in a shared mixin since a number of services could need it
    ../../mixins/permissions/groups/media.nix
  ];

  services.jellyfin = {
    enable = true;
    inherit dataDir;
    group = "media-server";
    # Plain HTTP port for tailnet and LAN clients. Transport is encrypted by
    # WireGuard on tailnet; application-layer TLS terminates at Caddy for
    # ${external_domain} via Cloudflare DNS-01 certificates.
    openFirewall = true;
  };

  # Securely mount Age secret for Cloudflare DNS verification config.
  # Read by systemd (as root) into the Caddy service environment.
  age.secrets.cloudflare-dns-verification = {
    file = ../../../secrets/services/acme/cloudflare.age;
    owner = "root";
    group = "root";
    mode = "400";
  };

  # Caddy owns ports 80/443 on this host (see hass.nix); Jellyfin shares it
  # rather than introducing nginx alongside it. The cloudflare DNS plugin
  # enables DNS-01 challenges so ${external_domain} can be served on the LAN
  # without inbound port forwarding.
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-F7d4HwM4oCkQrFMr4SFSC0r52ONxY+PW6z5BJawW8Ok=";
    };
    virtualHosts."${external_domain}".extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
      }
      reverse_proxy 127.0.0.1:8096
    '';
  };

  systemd.services.caddy = {
    serviceConfig.EnvironmentFile = config.age.secrets.cloudflare-dns-verification.path;
    after = [ "agenix-cloudflare-dns-verification.service" ];
    wants = [ "agenix-cloudflare-dns-verification.service" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ]; # HTTP/3
  };
}
