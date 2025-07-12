{ pkgs, lib, config, ... }:
let
  greetPkg = pkgs.greetd.tuigreet;
  greetPath = "${greetPkg}/bin/tuigreet";

  hyprland = config.programs.hyprland.package;

  cfg = config.ominix;
in { 
  services.getty.autologinOnce = true;

  services.greetd = {
    package = greetPkg;

    settings = rec {
      default_session = initial_session;
      initial_session = {
        inherit (cfg) user;
        command = "${greetPath} --cmd ${hyprland}";
      };
    };
  };
}
