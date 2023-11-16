{ pkgs, config, ...}:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  imports = [
    ../av/vulkan.nix
  ];

  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [
        nvidiaPackage.bin
        nvidiaPackage.lib32
      ];
    })
    wineWowPackages.stable
    winetricks
  ];
}
