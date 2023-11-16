{ pkgs, config, lib, ... }:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    nvtop
    nvidiaPackage.bin
  ];

  hardware.opengl = {
    enable = true;
    package = lib.mkForce nvidiaPackage.bin;
    package32 = lib.mkForce nvidiaPackage.lib32;
    extraPackages = lib.mkForce [];
    extraPackages32 = lib.mkForce [];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    powerManagement = {
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      finegrained = false;
    };

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
    package = nvidiaPackage;

    # In order to resolve screentearing issues
    forceFullCompositionPipeline = true;

    # Disable ALL Prime settings
    prime = {
      sync.enable = false;
      reverseSync.enable = false;
      offload.enable = false;
    };
  };

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