# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # (import ./disks.nix { }) # TODO: Incorporate diskos
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/bluetooth.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/services/tailscale.nix
    ../_mixins/virt
  ];

  swapDevices = [{
    device = "/swap";
    size = 4096;
  }];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_3;
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    # initrd.kernelModules = [ ];
    # initrd.availableKernelModules = [ "ahci" "nvme" "uas" "usbhid" "sd_mod" "xhci_pci" ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-amd" "nvidia" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8f20ce4f-86f8-43cb-9cb4-fac7274e1678";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/3B44-A0B6";
      fsType = "vfat";
    };

  fileSystems."/data/ssd2" =
    { device = "/dev/disk/by-uuid/f19f8a02-91b4-4238-9a66-575755caac2e";
      fsType = "ext4";
    };

  swapDevices = [ ];

  environment.systemPackages = with pkgs; [
    nvtop
  ];

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
    xserver.videoDrivers = [ "nvidia" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
