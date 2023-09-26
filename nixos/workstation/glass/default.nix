# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ inputs, lib, config, pkgs, modulesPath, ... }:
let
  containerization = "docker";
in
{
  imports = [
    # TODO: Incorporate diskos
    # (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../_mixins/desktop/helix.nix
    ../../_mixins/desktop/steam.nix
    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/services/pipewire.nix
    ../../_mixins/services/tailscale-autoconnect.nix
    ../../_mixins/virt
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    extraModulePackages = [ ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" "nvidia" ];
    # kernelModules = [ "kvm-amd" ];
  };

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
