# Motherboard: ASRock X570M Pro4
# CPU:         AMD Ryzen 9 3900X
# GPU:         NVIDIA GeForce GTX 1080 Ti
# RAM:         64GB DDR4
# SATA:        500GB SSD
# SATA:        500GB SSD
# SATA:        2TB SSHD

{ config, inputs, lib, pkgs, desktop, ... }: {
  imports = [
    (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # Ominix defines Nvidia hardware config
    # ../../mixins/hardware/gtx-1080ti.nix
    ../../mixins/hardware/roccat.nix
    ../../mixins/hardware/systemd-boot.nix
    # ../../mixins/network-shares/ds418-nfs.nix
    ../../mixins/services/nordvpn.nix
    ../../mixins/services/pipewire.nix

    ../../mixins/users/grigori/default.nix

    ../../mixins/servers/pixiecore-pxe.nix
  ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

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

  ominix.hardware.gpu.nvidia = true;
  virtualisation.docker.enable = false; 


  services.ollama = {
    package = pkgs.unstable.ollama-cuda;
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      # Adjust this to the best context length for Qwen3 30B A3B model AI!
      OLLAMA_CONTEXT_LENGTH = "8192";
    };
    # TODO: Restrict to tailnet IP
    # host = tailnetMatrix.hosts.glass;
    loadModels = [
      "qwen3:8b" # "hf.co/Qwen/Qwen3-8B"
      "starcoder2:7b" # "hf.co/bigcode/starcoder2-7b"
      "hf.co/unsloth/Qwen3-30B-A3B-GGUF:latest"
      # "hf.co/bunnycore/Qwen2.5-7B-Instruct-Fusion"
      # "hf.co/bunnycore/Qwen2.5-7B-CyberRombos"
    ];
  };

  boot = {
    # TODO: Enable Zen kernel after triaging Nvidia graphics issues
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages = pkgs.linuxKernel.packages.linux_6_6; # previous kernel in 24.11

    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "nvme" ];
    initrd.kernelModules = [ "nvidia" ];
    kernelModules = [ "kvm-amd" "nvidia" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
  };


  environment.systemPackages = with pkgs; [
    aider-chat
    distrobox
    google-fonts
    tmux
  ];

  # support for cross-platform NixOS builds
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
