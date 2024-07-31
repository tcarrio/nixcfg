# Device:      Dell Latitude E5470
# CPU:         Intel i7-6820HQ
# RAM:         32GB DDR3
# SATA:        120GB SSD
# SATA:        500GB SSD

{ inputs, lib, pkgs, ... }:
{
  imports = [
    # TODO: Incorporate diskos
    (import ./disks.nix { })

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # fix for nixos-rebuild hangups on certain hardware
    ../../_mixins/hardware/disable-nm-wait.nix

    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/services/pipewire.nix
    ../../_mixins/services/yubikey.nix
  ];

  config.oxc = {
    containerization = {
      enable = true;
      engine = "podman";
    };
    desktop.discord.enable = true;
    services.wait-online.disable = true;
    services.tailscale.enable = true;
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # internet
    firefox
    google-chrome

    # communication
    element-desktop
    slack
    zoom-us

    # design
    blender
    gimp
    inkscape

    # security
    bitwarden
    tor-browser-bundle-bin

    # development
    git
    python3

    # tools
    curl
    htop
    neofetch
    tilix
    vim
    wget

    # games
    dwarf-fortress
  ];

  services = { };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
