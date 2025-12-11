{ lib, config, ... }:
let
  cfg = config.oxc.desktop.aqua;

  inherit (lib) mkOption types;
in
{
  options.oxc.desktop.aqua = {
    workspaces.allowApplicationFocus = mkOption {
      type = types.bool;
      default = true;
      description = "Allows opening an application in another workspace to focus that workspace.";
    };
    workspaces.dynamic = mkOption {
      type = types.bool;
      default = false;
      description = "Allows macOS to re-order workspaces based on a most-recently-used algorithm.";
    };
  };

  config = {
    system.defaults.CustomUserPreferences = {
      "com.apple.dock" = {
        # Fast mode for application switching across workspaces with app launchers
        "workspaces-auto-swoosh" = cfg.workspaces.allowApplicationFocus;
        # Allows macOS to re-arrange spaces ordering
        "mru-spaces" = cfg.workspaces.dynamic;
      };
    };
  };
}
