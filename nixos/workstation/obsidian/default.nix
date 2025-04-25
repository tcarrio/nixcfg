# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ inputs, lib, pkgs, desktop, ... }: {
  imports = [
    (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../mixins/hardware/gtx-1080ti.nix
    ../../mixins/hardware/roccat.nix
    ../../mixins/hardware/systemd-boot.nix
    ../../mixins/network-shares/ds418-nfs.nix
    ../../mixins/services/nordvpn.nix
    ../../mixins/services/pipewire.nix
    ../../mixins/services/rustdesk.nix
    # ../../mixins/services/hoarder-compose.nix

    ../../mixins/users/grigori/default.nix

    ../../mixins/servers/pixiecore-pxe.nix
  ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  # TUI CHALLENGE TIME
  services.xserver.enable = true; # TODO: Remove lightdm
  services.xserver.windowManager.vtm.enable = true;
  # services.displayManager.ly.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+vtm";
  # services.xserver.displayManager.autoLogin = {
  #   user = "tcarrio";
  #   enable = true;
  # };

  oxc = {
    services = {
      nextdns.enable = false;
      noisetorch.enable = true;
      wait-online.enable = false;
      tailscale.enable = true;
      tailscale.autoconnect = false;
    };
    containerisation = {
      enable = true;
      engine = "podman";
      desktopApp = true;
    };
    virtualisation.enable = true;
  };

  ## TODO: Enable Ollama for obsidian?
  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";
  #   host = tailnetMatrix.hosts.glass;
  # };

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


  environment.systemPackages = with pkgs; [
    distrobox
    google-fonts
    tmux
  ];

  # support for cross-platform NixOS builds
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
