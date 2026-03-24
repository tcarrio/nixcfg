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
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks-hdds.nix { })
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

  # Services
  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;

  services.pocket-id.enable = true;
  services.pocket-id.settings.APP_URL = "http://${config.oxc.tailnet.hosts."${hostname}"}";

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
