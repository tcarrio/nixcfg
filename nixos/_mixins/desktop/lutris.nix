{ pkgs, ...}:
{
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    lutris
    wineWowPackages.stable
    winetricks
  ];
}
