# see install/nvidia.sh
{ config, pkgs, lib, ... }:
let
  cfg = config.ominix;
  mkOminixDefault = value: lib.mkOverride 999 value;
in {
  config = lib.mkIf (cfg.enable && cfg.hardware.gpu.nvidia) {
    environment.systemPackages = with pkgs; [ vulkan-tools nvtopPackages.full ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        modesetting.enable = mkOminixDefault true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = mkOminixDefault false;

        # Only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = mkOminixDefault false;

        # Use the NVidia open source kernel module:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        open = mkOminixDefault false;

        nvidiaSettings = mkOminixDefault true;

        forceFullCompositionPipeline = mkOminixDefault true;
      };

      graphics = {
        enable = mkOminixDefault true;
        package = mkOminixDefault config.hardware.nvidia.package;
      };
    };

    virtualisation.docker.enableNvidia = config.virtualisation.docker.enable;

    # TODO: Support for injecting environment variables into Hyprland config
  };
}
