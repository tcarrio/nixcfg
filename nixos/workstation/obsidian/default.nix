# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ inputs, lib, pkgs, ... }: {
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
    ## TODO: Enable the NFS share after configuring authentication
    # ../../mixins/network-shares/ds418-nfs.nix
    # ../../mixins/services/nordvpn.nix
    ../../mixins/services/pipewire.nix
    ../../mixins/users/grigori/default.nix
  ];

  oxc = {
    desktop = {
      daw.enable = true;
      fonts.ultraMode = true;
      ente.enable = true;
      logseq.enable = true;
      obs-studio.enable = true;
      steam = {
        enable = true;
        audioSupport.jack = true;
        audioSupport.pipewire = true;
        steamPlay.enable = true;
        steamPlay.firewall.open = true;
      };
      vscode = {
        enable = true;
        support = {
          bazel = true;
          elm = true;
          github = true;
          gitlens = true;
          go = true;
          grpc = true;
          linux = true;
          rust = true;
          ssh = true;
        };
        server.enable = true;
      };
      zed-editor.enable = false;
      zen-browser.enable = true;
    };
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
    tor-browser
    transmission_4-qt
    tmux
  ];

  # support for cross-platform NixOS builds
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
