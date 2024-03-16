{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/services/tailscale-autoconnect.nix
    ../../_mixins/virt
  ];

  # based on nixos-generators raw + raw-efi formats, see linked references
  fileSystems = {
    # https://github.com/nix-community/nixos-generators/blob/c1590ae68664e11c1acd03ec76c193a5c151a657/formats/raw.nix#L9
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
    # https://github.com/nix-community/nixos-generators/blob/c1590ae68664e11c1acd03ec76c193a5c151a657/formats/raw-efi.nix#L20
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  # ensure we aren't defaulting to NetworkManager with DHCP on
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp2s0";
    networkConfig = {
      # Address must be provided via systemd.network.networks."10-lan".networkConfig.Address
      Gateway = "192.168.40.1";
      DNS = "192.168.40.1";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
