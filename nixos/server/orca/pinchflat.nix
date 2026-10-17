{
  config,
  ...
}:
let
  external_domain = "pinchflat.carrio.me";
in
{
  # Native NixOS module (nixpkgs 26.05). State lives in /var/lib/pinchflat.
  # Secrets (SECRET_KEY_BASE, basic auth creds) come from agenix so they stay
  # out of the world-readable Nix store.
  services.pinchflat = {
    enable = true;
    # ZFS dataset zroot/media-youtube, created out of band (see repo docs on
    # ZFS management follow-up). Jellyfin reads it via the media-server group.
    mediaDir = "/media/youtube";
    # Port 8945 stays closed. All clients reach Pinchflat through Caddy at
    # ${external_domain} (HTTPS via Cloudflare DNS-01) on LAN and tailnet.
    openFirewall = false;
    # Shared group with Jellyfin (gid 1300) so its library scans can read
    # the downloaded media.
    group = "media-server";
    logLevel = "info";
    secretsFile = config.age.secrets.pinchflat-env.path;
  };

  age.secrets.pinchflat-env = {
    file = ../../../secrets/services/pinchflat/env.age;
    owner = "pinchflat";
    group = "media-server";
    mode = "440";
  };

  # The module only manages /var/lib/pinchflat; enforce ownership on the
  # media mountpoint itself, which ZFS mounts root-owned by default.
  systemd.tmpfiles.rules = [
    "d /media/youtube 0775 pinchflat media-server -"
  ];

  # Shares the Caddy + Cloudflare DNS-01 setup from media-server.nix, where
  # the CLOUDFLARE_DNS_API_TOKEN EnvironmentFile is wired into the service.
  services.caddy.virtualHosts."${external_domain}".extraConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:8945
  '';
}
