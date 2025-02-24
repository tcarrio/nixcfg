{ lib, config, ... }:
let
  tailnet = {
    domain = "griffin-cobra.ts.net";
    dns_resolver = "100.100.100.100";
  };

  plex = {
    external.fqdn = "media.carrio.me";

    upstream = rec {
      tailnet_fqdn = "orca.${tailnet.domain}";
      protocol = "http";
      port = "32400";
      proxy_url = "${protocol}://${tailnet_fqdn}:${port}/";
    };
  };

  hoarder = {
    external.fqdn = "hoarder.carrio.me";

    upstream = rec {
      tailnet_fqdn = "obsidian.${tailnet.domain}";
      protocol = "http";
      port = "3000";
      proxy_url = "${protocol}://${tailnet_fqdn}:${port}/";
    };
  };
in
{
  imports = [
    ../../mixins/disks/digital-ocean.nix
  ];

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
    defaults = {
      email = "tom@carrio.dev";
      renewInterval = "weekly";
      reloadServices = [ "nginx" ];
    };
    certs = {
      "${plex.external.fqdn}" = {
        domain = plex.external.fqdn;
        group = "nginx";
        dnsProvider = "cloudflare";

        # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
        environmentFile = config.age.secrets.cloudflare-dns-verification.path;
      };

      "${hoarder_fqdn}" = {
        domain = hoarder_fqdn;
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.age.secrets.cloudflare-dns-verification.path;
      };
    };
  };

  oxc.services.tailscale.enable = true;
  oxc.services.tailscale.autoconnect = false;
  services.smartd.enable = lib.mkForce false;

  # Plex NixOS Docs: https://nixos.wiki/wiki/Plex
  services.nginx = {
    enable = true;
    # give a name to the virtual host. It also becomes the server name.
    virtualHosts."${plex.external.fqdn}" = {
      # Since we want a secure connection, we force SSL
      forceSSL = true;

      # http2 can more performant for streaming: https://blog.cloudflare.com/introducing-http2/
      http2 = true;

      # Provide the ssl cert and key for the vhost
      sslCertificate = "/var/lib/acme/${plex.external.fqdn}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/${plex.external.fqdn}/key.pem";

      locations."/".proxyPass = plex.upstream.proxy_url;

      extraConfig = ''
        #Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
        send_timeout 100m;

        resolver ${tailnet.dns_resolver} valid=30s;

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
    };

    virtualHosts."${hoarder.external.fqdn}" = {
      forceSSL = true;
      http2 = true;

      sslCertificate = "/var/lib/acme/${hoarder.external.fqdn}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/${hoarder.external.fqdn}/key.pem";

      locations."/".proxyPass = hoarder.upstream.proxy_url;

      extraConfig = ''
        resolver ${tailnet.dns_resolver} valid=30s;

        # Why this is important: https://blog.cloudflare.com/ocsp-stapling-how-cloudflare-just-made-ssl-30/
        ssl_stapling on;
        ssl_stapling_verify on;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;

        # Forward real IP and host to upstream
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

        # Nginx default client_max_body_size is 1MB
        client_max_body_size 20M;

        # Websockets
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Buffering off send to the client as soon as the data is received from upstream.
        proxy_redirect off;
        proxy_buffering off;
      '';
    };

    virtualHosts."_" = {
      default = true;
      locations."/".return = "404 'GTFO'";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
