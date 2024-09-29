{ desktop, lib, pkgs, ... }: {
  imports = lib.optionals (desktop != null) [
    ../desktop/keybase.nix
  ];

  home.packages = with pkgs; [
    keybase
  ];

  services = {
    kbfs = {
      enable = true;
      mountPoint = "Keybase";
    };
  };
}
