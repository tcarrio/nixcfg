# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ pkgs, ... }:
{
  # Bluebox has an unfree license
  nixpkgs.config.allowUnfree = true;

  sk.enable = false;
  oxc.homebrew.enable = true;
  oxc.homebrew.defaults = true;
  oxc.services.colima = {
    enable = true;
    automaticBoot = true;
  };

  environment.systemPackages =
    (with pkgs.unstable; [
      openssh
      freetube
    ])
    ++ [
      pkgs.bluebox
    ];

  homebrew.casks = [
    "opencode-desktop"
    "synology-drive"
  ];
}
