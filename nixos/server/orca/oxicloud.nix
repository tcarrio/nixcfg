{
  config,
  lib,
  ...
}:
let
  external_domain = "oxicloud.carrio.me";
  port = 8086;

  # Gateway of docker's default bridge. The container reaches host services
  # through this address; postgres listens on it but the firewall stays
  # closed, so nothing off-host can connect.
  docker_host = "172.17.0.1";
in
{
  # --- Database: native NixOS postgres ---
  # The container connects over TCP to the host postgres instance. The
  # database and role are ensured declaratively; OxiCloud runs its own
  # embedded SQLx migrations at startup (src/infrastructure/db.rs), so no
  # external migration step is needed on the NixOS side.
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "oxicloud" ];
    ensureUsers = [
      {
        name = "oxicloud";
        ensureDBOwnership = true;
      }
    ];
    # Loopback plus the docker bridge gateway. postgres refuses to start if
    # it cannot bind a listed address, so order after docker (which creates
    # docker0).
    settings.listen_addresses = lib.mkForce "127.0.0.1, ${docker_host}";
    # Default HBA (peer/trust on loopback) plus scram for the container.
    authentication = lib.mkAfter ''
      host oxicloud oxicloud 172.16.0.0/12 scram-sha-256
    '';
  };

  systemd.services.postgresql = {
    after = [ "docker.service" ];
    # The role password is not representable in ensureUsers without landing
    # in the world-readable store, so apply it from the agenix secret on
    # every start. CREATE ROLE is guarded because ensureUsers runs later in
    # ExecStartPost and has not created the role yet on first boot.
    serviceConfig.LoadCredential = "oxicloud_env:${config.age.secrets.oxicloud-env.path}";
    preStart = ''
      PW="$(sed -n 's/^OXICLOUD_DB_PASSWORD=//p' "$CREDENTIALS_DIRECTORY/oxicloud_env")"
      if [ -n "$PW" ]; then
        PSQL="${config.services.postgresql.package}/bin/psql"
        if ! "$PSQL" -tAc "SELECT 1 FROM pg_roles WHERE rolname='oxicloud'" | grep -q 1; then
          "$PSQL" -c "CREATE ROLE oxicloud LOGIN"
        fi
        "$PSQL" -c "ALTER ROLE oxicloud WITH PASSWORD '$PW';"
      fi
    '';
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
    };

    # OXICLOUD_DB_CONNECTION_STRING (and the shared password copy) come from
    # agenix so they stay out of the world-readable Nix store.
    environmentFiles = [ config.age.secrets.oxicloud-env.path ];

    volumes = [
      "/var/lib/oxicloud/storage:/app/storage"
    ];

    extraOptions = [
      "--read-only"
      "--tmpfs=/tmp:rw,noexec,nosuid,size=128m"
      "--security-opt=no-new-privileges"
      "--cap-drop=ALL"
    ];
  };

  # Start only once postgres is up and the password has been applied.
  systemd.services."docker-oxicloud" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  age.secrets.oxicloud-env = {
    file = ../../../secrets/services/oxicloud/env.age;
    owner = "root";
    group = "root";
    mode = "400";
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
