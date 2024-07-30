# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ inputs, lib, pkgs, ... }: {
  imports = [
    # TODO: Incorporate diskos
    # (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../_mixins/hardware/gtx-1080ti.nix
    ../../_mixins/hardware/roccat.nix
    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/network-shares/ds418-nfs.nix
    ../../_mixins/services/nordvpn.nix
    ../../_mixins/services/pipewire.nix
    ../../_mixins/services/tailscale-autoconnect.nix
    ../../_mixins/virt
  ];

  config.oxc = {
    desktop = {
      daw.enable = true;
      ente.enable = true;
      logseq.enable = true;
      steam.enable = true;
    };
    services.wait-online.disable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_6_8;
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    extraModulePackages = [ ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" "nvidia" ];
  };

  environment.systemPackages = [
    pkgs.google-fonts
    pkgs.gnomeExtensions.gsconnect
  ];

  # support for cross-platform NixOS builds
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
      package = pkgs.openrgb-with-all-plugins;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
