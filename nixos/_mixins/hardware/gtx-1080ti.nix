{ pkgs, ... }: {
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    nvtop
  ];
}