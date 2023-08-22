# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        120GB SSD

{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # (import ./disks.nix { }) # TODO: Implement diskos
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/bluetooth.nix
    ../_mixins/services/maestral.nix
    ../_mixins/services/openrazer.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/services/tailscale.nix
    ../_mixins/services/zerotier.nix
    ../_mixins/virt
  ];

  fileSystems."/" = lib.mkForce 
    { device = "/dev/disk/by-uuid/140fca12-c2a2-411c-8b0f-1dd4547f1f0e";
      fsType = "ext4";
    };

  swapDevices = [{
    device = "/swap";
    size = 2048;
  }];

  boot = {
    # blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    initrd = {
      availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
      kernelModules = [ ];
      luks.devices."luks-1175ca46-0654-4ba3-b8bf-a82a29545879".device = "/dev/disk/by-uuid/1175ca46-0654-4ba3-b8bf-a82a29545879";
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment.systemPackages = with pkgs; [
  ];

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
