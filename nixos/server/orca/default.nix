# Motherboard: Supermicro X9SCL/X9SCM
# CPU:         Intel(R) Xeon(R) E3-1270 V2 (8) @ 3.50 GHz
# GPU:         Matrox Electronics Systems Ltd. X9SCM-F Motherboard
# RAM:         32GB DDR3
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
      "192.168.1.1"
    ];
    gateway = "192.168.1.1";
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
    ./disks.nix
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

  ### START SECTION: HOME ASSISTANT ###
  # Basic Home Assistant container
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      # "met"
      # "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      # Connect to local PostgreSQL service
      # recorder.db_url = "postgresql://@/hass";

      # Declarative automations
      "automation manual" = [
        ### EXAMPLES
        # {
        #   alias = "living room plug off";
        #   trigger = {
        #     platform = "time";
        #     at = "22:00";
        #   };
        #   action = {
        #     type = "turn_off";
        #     device_id = "someID"; #Inspect yaml of automation created in UI
        #     entity_id = "switch.living_room_plug";
        #     domain = "switch";
        #   };
        # }
      ];
      # Automations configured in the UI
      "automation ui" = "!include automations.yaml";
    };
    # Ensure support for PostgreSQL driver
    # package = (pkgs.home-assistant.override {
    #   extraPackages = py: with py; [ psycopg2 ];
    # }).overrideAttrs (oldAttrs: {
    #   doInstallCheck = false;
    # });
  };
  # Enable and set up Home Assistant on PostgreSQL
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "hass" ];
  #   ensureUsers = [{
  #     name = "hass";
  #     ensureDBOwnership = true;
  #   }];
  # };
  # Add-ons that depend on SSL 1.x may require the following insecure package be permitted
  # nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];
  # Enable Caddy reverse proxy, listening for Tailnet host requests
  services.caddy = {
    enable = true;
    virtualHosts."orca.griffin-cobra.ts.net".extraConfig = ''
      reverse_proxy 127.0.0.1:8123
    '';
  };
  networking.firewall.allowedTCPPorts = [ 443 ];
  # Allow Caddy to generate certificates
  services.tailscale.permitCertUid = "caddy";
  # Ensure the Caddy server starts after Tailscale authentication
  systemd.services.caddy.after = ["tailscaled-autoconnect.service"];
  ### END SECTION: HOME ASSISTANT ###

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
  networking.hostId = builtins.hashString "sha512" hostname
    |> builtins.substring 0 8;

  systemd.network.networks."20-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp2s0";
    address = "192.168.1.251/24";
  };
  systemd.network.networks."30-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp3s0";
    address = "192.168.1.250/24";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.zfs.autoSnapshot = {
    enable = true;
    # datasets have specific snapshot retention defined explicitly.
    frequent = 0;
    hourly = 0;
    daily = 60;
    weekly = 0;
  };
}
