{
  config,
  pkgs,
  ...
}:
let
  external_domain = "media.carrio.me";
  dataDir = "/data/media";
  # Claimed centrally in ports.nix; the oxc.ports assertion blocks
  # collisions with other services at eval time.
  port = config.oxc.ports.jellyfin;
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
    # Port ${toString port} stays closed. All clients reach Jellyfin through
    # Caddy at ${external_domain} (HTTPS via Cloudflare DNS-01) on LAN and
    # tailnet. (The jellyfin module has no port option — 8096 is hardcoded
    # upstream; the claim documents it and feeds the Caddy target below.)
    openFirewall = false;
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
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
    virtualHosts."${external_domain}".extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
      }
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  systemd.services.caddy = {
    serviceConfig.EnvironmentFile = config.age.secrets.cloudflare-dns-verification.path;
    # No ordering deps on agenix units: current agenix installs secrets via
    # activation scripts (agenixInstall) or agenix-install-secrets.service,
    # both of which complete before regular services start.
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ]; # HTTP/3
  };
}
