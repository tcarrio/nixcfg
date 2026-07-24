{ pkgs, config, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      vulkan-tools
      nvtopPackages.full
    ];

    # variables = {
    #   VK_DRIVER_FILES = builtins.concatStringsSep ":" vulkanDriverFiles;
    # };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      open = false;

      nvidiaSettings = true;

      # Disabled: this is an Xorg-era tearing fix that conflicts with Mutter's
      # compositor vsync under GNOME Wayland and can reduce OpenGL performance.
      # modesetting.enable above already gives us the correct Wayland path via
      # nvidia-drm, so this isn't needed.
      forceFullCompositionPipeline = false;
    };

    # package defaults to pkgs.mesa; the NVIDIA module layers the proprietary
    # userspace on top via hardware.graphics.extraPackages, which is the setup
    # the module is designed around.
    graphics.enable = true;
  };
}
