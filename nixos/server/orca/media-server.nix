{ pkgs, config, ... }:
let
  external_domain = "media.carrio.me";
  # internal_domain = "media.int.carrio.me";
  tailnet_domain = "orca.griffin-cobra.ts.net";
  dataDir = "/data/media";

  acmeCertConfig = {
    group = "nginx";
    dnsProvider = "cloudflare";

    # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
    environmentFile = config.age.secrets.cloudflare-dns-verification.path;
  };

  jellyfinExtraConfig = ''
    ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
    client_max_body_size 20M;

    # Comment next line to allow TLSv1.0 and TLSv1.1 if you have very old clients
    ssl_protocols TLSv1.3 TLSv1.2;

    # use a variable to store the upstream proxy
    set $jellyfin 127.0.0.1;

    # Security / XSS Mitigation Headers
    add_header X-Content-Type-Options "nosniff";

    # Permissions policy. May cause issues with some clients
    add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

    # Content Security Policy
    # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
    # Enforces https content and restricts JS/CSS to origin
    # External Javascript (such as cast_sender.js for Chromecast) must be whitelisted.
    add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";
  '';

  jellyfinMainRouteConfig = ''
    # location / : Proxy main Jellyfin traffic
    proxy_pass http://$jellyfin:8096;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Protocol $scheme;
    proxy_set_header X-Forwarded-Host $http_host;

    # Disable buffering when the nginx proxy gets very resource heavy upon streaming
    proxy_buffering off;
  '';

  jellyfinSocketRouteConfig = ''
    # location /socket : Proxy Jellyfin Websockets traffic
    proxy_pass http://$jellyfin:8096;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Protocol $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';

  jellyfinVirtualHostConfig = {
    # Disallow insecure HTTP connection
    forceSSL = true;
    # http2 can more performant for streaming: https://blog.cloudflare.com/introducing-http2/
    http2 = true;

    extraConfig = jellyfinExtraConfig;
    locations."/".extraConfig = jellyfinMainRouteConfig;
    locations."/socket".extraConfig = jellyfinSocketRouteConfig;
  };
in
{
  imports = [
    # Definition for a common group for media services like Plex and Jellyfin
    # This is in a shared mixin since a number of services could need it
    ../../mixins/permissions/groups/media.nix
  ];

  # services.plex = {
  #   inherit dataDir;
  #   enable = true;
  #   # Exposes on the local intranet
  #   openFirewall = true;

  #   # Various media services are granted necessary access to volumes via 'media-server' group
  #   group = "media-server";
  # };

  services.jellyfin = {
    enable = true;
    inherit dataDir;
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
      # "${internal_domain}" = acmeCertConfig // {
      #   domain = internal_domain;
      # };
      "${external_domain}" = acmeCertConfig // {
        domain = external_domain;
      };
    };
  };

  systemd.services."provision-tailnet-certificate" = {
    wants = [ "tailscale.service" ];
    path = with pkgs; [
      tailscale
      jq
    ];
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
    # virtualHosts."${internal_domain}" = jellyfinVirtualHostConfig // {
    #   sslCertificate = "/var/lib/acme/${internal_domain}/fullchain.pem";
    #   sslCertificateKey = "/var/lib/acme/${internal_domain}/key.pem";
    # };

    virtualHosts."${tailnet_domain}" = jellyfinVirtualHostConfig // {
      sslCertificate = "/var/lib/acme/${tailnet_domain}/cert.pem";
      sslCertificateKey = "/var/lib/acme/${tailnet_domain}/key.pem";
    };

    virtualHosts."${external_domain}" = jellyfinVirtualHostConfig // {
      sslCertificate = "/var/lib/acme/${external_domain}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/${external_domain}/key.pem";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ];
  };
}
