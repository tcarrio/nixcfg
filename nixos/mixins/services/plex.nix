{ pkgs, config, ... }:
let
  external_domain = "media.carrio.me";
  internal_domain = "media.int.carrio.me";
  tailnet_domain = "glass.griffin-cobra.ts.net";
  dataDir = "/data/plex/plex/";

  acmeCertConfig = {
    group = "nginx";
    dnsProvider = "cloudflare";

    # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
    environmentFile = config.age.secrets.cloudflare-dns-verification.path;
  };

  extraConfig = ''
    #Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
    send_timeout 100m;

    # Why this is important: https://blog.cloudflare.com/ocsp-stapling-how-cloudflare-just-made-ssl-30/
    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    #Intentionally not hardened for security for player support and encryption video streams has a lot of overhead with something like AES-256-GCM-SHA384.
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

    # Forward real ip and host to Plex
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $server_addr;
    proxy_set_header Referer $server_addr;
    proxy_set_header Origin $server_addr;

    # Plex has A LOT of javascript, xml and html. This helps a lot, but if it causes playback issues with devices turn it off.
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_proxied any;
    gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
    gzip_disable "MSIE [1-6]\.";

    # Nginx default client_max_body_size is 1MB, which breaks Camera Upload feature from the phones.
    # Increasing the limit fixes the issue. Anyhow, if 4K videos are expected to be uploaded, the size might need to be increased even more
    client_max_body_size 100M;

    # Plex headers
    proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
    proxy_set_header X-Plex-Device $http_x_plex_device;
    proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
    proxy_set_header X-Plex-Platform $http_x_plex_platform;
    proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
    proxy_set_header X-Plex-Product $http_x_plex_product;
    proxy_set_header X-Plex-Token $http_x_plex_token;
    proxy_set_header X-Plex-Version $http_x_plex_version;
    proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
    proxy_set_header X-Plex-Provides $http_x_plex_provides;
    proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
    proxy_set_header X-Plex-Model $http_x_plex_model;

    # Websockets
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Buffering off send to the client as soon as the data is received from Plex.
    proxy_redirect off;
    proxy_buffering off;
  '';

  baseVirtualHostConfig = {
    # Disallow insecure HTTP connection
    forceSSL = true;
    # http2 can more performant for streaming: https://blog.cloudflare.com/introducing-http2/
    http2 = true;

    inherit extraConfig;

    locations."/" = {
      proxyPass = "http://127.0.0.1:32400/";
    };
  };
in
{
  imports = [
    # Definition for a common group for media services like Plex and Jellyfin
    # This is in a shared mixin since a number of services could need it
    ../permissions/groups/media.nix
  ];

  services.plex = {
    inherit dataDir;
    enable = true;
    # Exposes on the local intranet
    openFirewall = true;

    # Various media services are granted necessary access to volumes via 'media-server' group
    group = "media-server";
  };

  # Securely mount Age secret for Cloudflare DNS verification config
  age.secrets.cloudflare-dns-verification = {
    file = ../../../secrets/services/acme/cloudflare.age;
    owner = "root";
    group = "root";
    mode = "400";
  };

  # ACME NixOS Docs: https://wiki.nixos.org/wiki/ACME
  security.acme = {
    acceptTerms = true;
    defaults.email = "tom@carrio.dev";
    certs = {
      "${internal_domain}" = acmeCertConfig // {
        domain = internal_domain;
      };
      "${external_domain}" = acmeCertConfig // {
        domain = external_domain;
      };
    };
  };

  systemd.services."provision-tailnet-certificate" = {
    wants = [ "tailscale.service" ];
    path = with pkgs; [ tailscale jq ];
    script = with pkgs; ''
      if ! ${tailscale}/bin/tailscale status; then
        exit 7
      fi

      mkdir -p /var/lib/acme/${tailnet_domain}/

      ${tailscale}/bin/tailscale cert \
        --cert-file=/var/lib/acme/${tailnet_domain}/cert.pem \
        --key-file=/var/lib/acme/${tailnet_domain}/key.pem \
        --min-validity=48h \
        ${tailnet_domain}
      
      chown -R ${config.services.nginx.user}:${config.services.nginx.group} /var/lib/acme/${tailnet_domain}
    '';
  };

  systemd.timers."provision-tailnet-certificate-cron" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "12h";
      Unit = "provision-tailnet-certificate.service";
    };
  };

  # Plex NixOS Docs: https://nixos.wiki/wiki/Plex
  services.nginx = {
    enable = true;
    virtualHosts."${internal_domain}" = baseVirtualHostConfig // {
      sslCertificate = "/var/lib/acme/${internal_domain}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/${internal_domain}/key.pem";
    };

    virtualHosts."${tailnet_domain}" = baseVirtualHostConfig // {
      sslCertificate = "/var/lib/acme/${tailnet_domain}/cert.pem";
      sslCertificateKey = "/var/lib/acme/${tailnet_domain}/key.pem";
    };

    virtualHosts."${external_domain}" = baseVirtualHostConfig // {
      sslCertificate = "/var/lib/acme/${external_domain}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/${external_domain}/key.pem";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ];
  };
}
