{ pkgs, config, ...}:
{
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [
        config.boot.kernelPackages.nvidiaPackages.stable
      ];
    })
    wineWowPackages.stable
    winetricks
  ];
}
