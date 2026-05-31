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
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "America/Detroit";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [ 
        "--network=host" 
        "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
  };
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
