{
  config,
  ...
}:
let
  external_domain = "paperless.carrio.me";
  # Claimed centrally in ports.nix; the oxc.ports assertion blocks
  # collisions with other services at eval time.
  port = config.oxc.ports.paperless;
in
{
  # Native NixOS module (nixpkgs). Full architecture: paperless-web
  # (gunicorn), paperless-scheduler + paperless-task-queue + paperless-
  # consumer (celery), a dedicated redis-paperless instance (unix socket,
  # no TCP), a paperless database on the host postgres (peer auth over
  # /run/postgresql like oxicloud/dawarich), and tika + gotenberg for
  # OCR of Office/e-mail attachments (configureTika). Database migration
  # runs automatically when the package version changes; the superuser is
  # provisioned from the agenix password secret below.
  services.paperless = {
    enable = true;
    inherit port;
    domain = external_domain; # sets PAPERLESS_URL for CSRF behind the proxy
    configureNginx = false; # Caddy owns 80/443 on this host
    database.createLocally = true;
    configureTika = true;
    passwordFile = config.age.secrets.paperless-password.path;
  };

  # Gotenberg's upstream default port is 3000, which collides with trek's
  # loopback publish (runtime bind conflict, invisible to eval). Pin it to
  # its own claim; tika keeps its default but is claimed and pinned so the
  # map stays the single source of truth.
  services.gotenberg.port = config.oxc.ports.gotenberg;
  services.tika.port = config.oxc.ports.tika;

  # Initial admin password for the web UI (user "admin"); rotate it in the
  # UI after first login.
  age.secrets.paperless-password = {
    file = ../../secrets/services/paperless/password.age;
    owner = "root";
    group = "root";
    mode = "400";
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
