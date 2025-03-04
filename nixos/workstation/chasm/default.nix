# Device:      Alienware Steam Machine ASM100
# CPU:         i3-4170T
# GPU:         NVIDIA GeForce 700M Series
# RAM:         4GB DDR3
# SATA:        120GB SSD

{ inputs, lib, pkgs, desktop, ... }: {
  imports = [
    (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../mixins/hardware/systemd-boot.nix
  ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  oxc = {
    services = {
      wait-online.enable = false;
      tailscale.enable = true;
      tailscale.autoconnect = false;
    };
    containerisation.enable = false;
    virtualisation.enable = false;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    extraModulePackages = [ ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "nvme" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" "nvidia" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
  };

  # Kepler architecture configurations
  hardware.nvidia.forceFullCompositionPipeline = true;
  hardware.nvidia.open = false;

  environment.systemPackages = with pkgs; [
    tmux
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
