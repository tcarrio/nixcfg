# Device:      Dell Latitude E5470
# CPU:         Intel i7-6820HQ
# RAM:         32GB DDR3
# SATA:        120GB SSD
# SATA:        500GB SSD

{ inputs, lib, pkgs, ... }:
{
  imports = [
    (import ./disks.nix { })

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../mixins/hardware/grub-legacy-boot.nix
    ../../mixins/hardware/intel.accelerated-video-playback.nix
    ../../mixins/services/pipewire.nix
  ];

  oxc = {
    containerisation = {
      enable = true;
      engine = "podman";
    };
    desktop = {
      bitwarden.enable = true;
      discord.enable = true;
      vscode.enable = true;

      # override default browser
      zen-browser.enable = true;
      google-chrome.enable = true;
      chromium.enable = lib.mkForce false;
      firefox.enable = lib.mkForce false;
    };
    services = {
      wait-online.enable = false;
      tailscale.enable = true;
    };
    virtualisation.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];

    extraModulePackages = [ ];
  };

  environment.systemPackages = with pkgs; [
    blender
    gimp
    inkscape
    tor-browser-bundle-bin
    git
    python3
    curl
    htop
    neofetch
    wget
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
