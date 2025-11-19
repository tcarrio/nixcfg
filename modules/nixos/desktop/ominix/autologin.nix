{ pkgs, lib, config, ... }:
let
  greetPkg = pkgs.greetd.tuigreet;
  greetPath = "${greetPkg}/bin/tuigreet";

  hyprland = config.programs.hyprland.package;

  cfg = config.ominix;
in { 
  services.greetd = lib.mkIf cfg.enable {
    enable = true;
    package = greetPkg;
    settings = rec {
      default_session = initial_session;
      initial_session = {
        inherit (cfg) user;
        command = "${greetPath} --cmd ${hyprland}/bin/hyprland";
      };
    };
  };
}
