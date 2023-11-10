{ pkgs, config, ... }: {
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    nvtop
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = [config.boot.kernelPackages.nvidiaPackages.beta];
    extraPackages32 = [config.boot.kernelPackages.nvidiaPackages.beta];
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # In order to resolve screentearing issues
    forceFullCompositionPipeline = true;
  };

  services.xserver.videoDrivers = ["nvidia"];


  ## TODO: if this is useful, nixify
  # nix-store --query --graph /run/current-system \
  # | grep -e "steam-fhs" \
  # | grep -e "nvidia" \
  # | awk '{print $1}' \
  # | sed 's/"//g' \
  # | sed -E 's#^#/nix/store/#' \
  # | while read dir; find $dir -name "nvidia_icd*.json"; end
  ## results in paths to the ICD files that can be set in the env e.g.
  # export VK_ICD_FILENAMES=/nix/store/abc-nvidia-x11-535.86.05-6.5.10/share/vulkan/icd.d/nvidia_icd.x86_64.json:...
}