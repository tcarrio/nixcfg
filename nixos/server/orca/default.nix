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
    dns = [ "192.168.1.1" ];
    gateway = [ "192.168.1.1" ];
  };
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./disks.nix
    ./hass.nix
    # ./haos.nix
    # ./media-server.nix
    ../../mixins/hardware/grub-legacy-boot.nix
    # "${inputs.nixpkgs-unstable}/nixos/modules/services/home-automation/home-assistant.nix"
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
  networking.hostId = builtins.hashString "sha512" hostname |> builtins.substring 0 8;

  systemd.network.enable = true;
  systemd.network.networks."20-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp2s0";
    address = [ "192.168.1.251/24" ];
  };
  systemd.network.networks."30-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "eno1";
    address = [ "192.168.1.250/24" ];
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
  # Disable force import to avoid data loss scenarios
  boot.zfs.forceImportRoot = false;
}
