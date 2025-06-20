{ pkgs, config, ... }:
let
  ## TODO: Remove manual definition
  # vulkanDriverFiles = [
  #   "${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.x86_64.json"
  #   "${config.hardware.nvidia.package.lib32}/share/vulkan/icd.d/nvidia_icd.i686.json"
  # ];
in
{
  environment = {
    systemPackages = with pkgs; [ vulkan-tools nvtopPackages.full ];

    # variables = {
    #   VK_DRIVER_FILES = builtins.concatStringsSep ":" vulkanDriverFiles;
    # };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      open = false;

      nvidiaSettings = true;

      forceFullCompositionPipeline = true;
    };

    graphics = {
      enable = true;
      inherit (config.hardware.nvidia) package;
    };
  };

  virtualisation.docker.enableNvidia = config.oxc.virtualisation.enable;
}
