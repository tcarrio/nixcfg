# Motherboard: Supermicro X9SCL/X9SCM
# CPU:         Intel Celeron G1610T (2) @ 2.300GHz
# GPU:         Matrox Electronics Systems Ltd. X9SCM-F Motherboard
# RAM:         16GB DDR3
# SATA:        WD 300GB HDD
# SATA:        Corsair 256G
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD

{
  inputs,
  lib,
  pkgs,
  hostname,
  config,
  ...
}:
let
  inetConfig = {
    dns = [
      "45.90.28.130"
      "45.90.30.130"
    ];
    gateway = "192.168.40.1";
  };
  externalHostnames = rec {
    base = "carrio.me";
    auth = "auth.${base}";
  };
  tailhost = config.oxc.tailnet.hosts.${hostname};
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./disks-hdds.nix
    ../../mixins/hardware/grub-legacy-boot.nix
  ];

  boot.swraid = {
    enable = true;
    mdadmConf = "MAILADDR=dev-null@carrio.dev";
  };

  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  oxc.services.tailscale = {
    enable = true;
    autoconnect = true;
    ssh.enable = true;
  };

  ### Services ###
  oxc.services.acme.enable = true;
  oxc.services.acme.nginx.hosts = [externalHostnames.auth];

  # PocketID for centralized auth based on passkeys
  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://${externalHostnames.auth}";
      HOST = tailhost;
      PORT = "1411";
      ANALYTICS_DISABLED = true;
    };
  };
  services.nginx.virtualHosts."${externalHostnames.auth}" = {
    http2 = true;
    locations."/".proxyPass = "http://${tailhost}:${config.services.pocket-id.settings.PORT or "1411"}";
    extraConfig = ''
      resolver ${config.oxc.tailnet.dns} valid=30s;

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

  # Hardware config

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usbhid"
      "uas"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  # Use passed hostname to configure basic networking
  networking.hostName = hostname;

  systemd.network.networks."20-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp2s0";
    address = "192.168.40.251/24";
  };
  systemd.network.networks."30-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp3s0";
    address = "192.168.40.250/24";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
