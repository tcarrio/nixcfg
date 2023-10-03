{ pkgs, ... }: {
  imports = [
    ../av/vulkan.nix
  ];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      
      # Whether to use the open source kernel module
      # The GTX 1080 is not supported by the open source driver
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      open = false;
    };
  };

  environment.systemPackages = with pkgs; [
    nvtop
  ];
}