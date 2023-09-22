{ pkgs, config, ... }: {
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    nvtop
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}