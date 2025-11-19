{ config, lib, pkgs, ... }:
let
  cfg = config.oxc.sol;
in {
  options.oxc.sol.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Sol desktop environment";
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.extraActivation.text = ''
       osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Sol.app", hidden:false}'
    '';

    sk.spotlight.enable = false;
  };
}
