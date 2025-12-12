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

    # this system supports UEFI but was transitioned from a BIOS install
    ../../mixins/hardware/grub-legacy-boot.nix
    ../../mixins/services/pipewire.nix

    ../../mixins/console/tui.nix
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
      vscode.support.ai = true;
    };
    services = {
      mopidy.enable = false;
      wait-online.enable = false;
      tailscale.enable = true;
    };
    # virtualisation.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];

    extraModulePackages = [ ];
  };

  environment.systemPackages = with pkgs; [
    gimp
    inkscape
    tor-browser
    git
    python3
    curl
    htop
    neofetch
    wget
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
