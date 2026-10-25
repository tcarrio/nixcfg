{
  lib,
  ...
}:
let
  external_domain = "oxicloud.carrio.me";
  port = 8086;

  # The image runs the app as uid 1001 ("oxicloud" inside the container).
  # Declaring a matching host user lets the container authenticate to the
  # host postgres over the unix socket with peer auth — the same
  # no-credentials pattern native NixOS services use — so no password
  # exists to distribute.
  app_uid = 1001;
in
{
  # --- Database: native NixOS postgres ---
  # The container connects via the /run/postgresql socket (bind-mounted
  # read-write); pg_hba's default `local all all peer` line authenticates
  # the socket peer by uid. The database and role are ensured declaratively;
  # OxiCloud runs its own embedded SQLx migrations at startup
  # (src/infrastructure/db.rs), so no external migration step is needed on
  # the NixOS side.
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "oxicloud" ];
    ensureUsers = [
      {
        name = "oxicloud";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.oxicloud = {
    uid = lib.mkDefault app_uid;
    isSystemUser = true;
    group = "nogroup";
  };

  # --- Application container ---
  # OCI container (docker.io/diocrafts/oxicloud). No native NixOS module
  # upstream. State: blobs under /var/lib/oxicloud/storage (chown-entrusted
  # to the image's entrypoint), database in postgres above.
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.oxicloud = {
    image = "docker.io/diocrafts/oxicloud:0.9.3";
    autoStart = true;

    # Loopback-only publish; port stays closed off-host. Clients reach
    # OxiCloud through Caddy at ${external_domain}.
    ports = [ "127.0.0.1:${toString port}:${toString port}" ];

    environment = {
      OXICLOUD_SERVER_HOST = "0.0.0.0"; # bind all interfaces inside the container
      OXICLOUD_SERVER_PORT = toString port;
      # Required when serving through a domain: auth validates against it.
      OXICLOUD_BASE_URL = "https://${external_domain}";
      # Disk-backed scratch dir instead of the container's tmpfs /tmp; video
      # EXIF probes stream blobs through here.
      OXICLOUD_TEMP_DIR = "/app/storage/tmp";
      OXICLOUD_STORAGE_PATH = "/app/storage";
      # Socket connection, peer auth: no password anywhere. Percent-encoded
      # host = unix socket directory (libpq/SQLx convention). Set via `-e`
      # so it overrides the image's built-in ENV default.
      OXICLOUD_DB_CONNECTION_STRING = "postgres://oxicloud@%2Frun%2Fpostgresql/oxicloud";
    };

    volumes = [
      "/var/lib/oxicloud/storage:/app/storage"
      # Socket dir, read-write: connecting to a unix socket requires write
      # access on the socket inode.
      "/run/postgresql:/run/postgresql"
    ];

    # The image entrypoint runs as root to chown /app/storage to the
    # unprivileged app user (uid 1001), then drops privileges via su-exec —
    # so CHOWN/SETUID/SETGID must survive the cap drop.
    extraOptions = [
      "--read-only"
      "--tmpfs=/tmp:rw,noexec,nosuid,size=128m"
      "--security-opt=no-new-privileges"
      "--cap-drop=ALL"
      "--cap-add=CHOWN"
      "--cap-add=SETUID"
      "--cap-add=SETGID"
    ];
  };

  # Start only once postgres is up (socket exists).
  systemd.services."docker-oxicloud" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/oxicloud/storage 0750 root root -"
  ];

  # Shares the Caddy + Cloudflare DNS-01 setup from media-server.nix, where
  # the CLOUDFLARE_DNS_API_TOKEN EnvironmentFile is wired into the service.
  services.caddy.virtualHosts."${external_domain}".extraConfig = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
