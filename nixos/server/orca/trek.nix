{
  config,
  ...
}:
let
  external_domain = "trek.carrio.me";
  port = 3000;
in
{
  # OCI container (docker.io/mauriceboe/trek). No native NixOS module exists
  # upstream; SQLite is embedded so no database service is needed. State lives
  # in /var/lib/trek/{data,uploads}. Mirrors the security defaults of TREK's
  # production docker-compose.yml (read-only rootfs, dropped capabilities,
  # no-new-privileges, tmpfs /tmp).
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.trek = {
    image = "docker.io/mauriceboe/trek:4.3.3";
    autoStart = true;

    # Loopback-only publish; port 3000 stays closed off-host. Clients reach
    # TREK through Caddy at ${external_domain}. Caddy handles the /ws
    # WebSocket upgrades transparently.
    ports = [ "127.0.0.1:${toString port}:${toString port}" ];

    environment = {
      NODE_ENV = "production";
      PORT = toString port;
      TZ = "UTC";
      ALLOWED_ORIGINS = "https://${external_domain}";
      # Behind Caddy TLS termination.
      TRUST_PROXY = "1";
    };

    # ENCRYPTION_KEY (openssl rand -hex 32) comes from agenix so it stays out
    # of the world-readable Nix store.
    environmentFiles = [ config.age.secrets.trek-env.path ];

    volumes = [
      "/var/lib/trek/data:/app/data"
      "/var/lib/trek/uploads:/app/uploads"
    ];

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

  age.secrets.trek-env = {
    file = ../../../secrets/services/trek/env.age;
    owner = "root";
    group = "root";
    mode = "400";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/trek/data 0750 root root -"
    "d /var/lib/trek/uploads 0750 root root -"
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
