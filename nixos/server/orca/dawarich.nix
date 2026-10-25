{
  config,
  ...
}:
let
  external_domain = "dawarich.carrio.me";
  # Claimed centrally in ports.nix; the oxc.ports assertion blocks
  # collisions with other services at eval time.
  port = config.oxc.ports.dawarich;
in
{
  # Native NixOS module (nixpkgs). State lives in /var/lib/dawarich; the
  # watched-folder import dir /var/lib/dawarich/imports/watched is created
  # via tmpfiles.
  #
  # Full Dawarich architecture is handled by the module: dawarich-web (puma),
  # dawarich-sidekiq-all (background imports/geocoding), a dedicated
  # redis-dawarich instance (unix socket, no TCP), and a dawarich database on
  # the host postgres (already enabled by oxicloud.nix) with the postgis
  # extension installed via postgresql-setup ExecStartPost. Peer auth over
  # /run/postgresql, same as oxicloud: no database password exists.
  # SECRET_KEY_BASE is auto-generated on first boot into
  # /var/lib/dawarich/secrets/secret-key-base; database migrations and seeds
  # run automatically (dawarich-init-db).
  services.dawarich = {
    enable = true;
    localDomain = external_domain;
    webPort = port;
    # Caddy owns 80/443 on this host; Rails serves its own static assets
    # (config.public_file_server.enabled = true), so a plain reverse_proxy
    # is sufficient without an nginx static root.
    configureNginx = false;
  };

  # Puma binds all interfaces (upstream puma.rb uses `port`, no bind
  # override), but the firewall contract keeps the service port closed
  # off-host; clients reach Dawarich through Caddy only.
  #
  # Shares the Caddy + Cloudflare DNS-01 setup from media-server.nix, where
  # the CLOUDFLARE_DNS_API_TOKEN EnvironmentFile is wired into the service.
  services.caddy.virtualHosts."${external_domain}".extraConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
