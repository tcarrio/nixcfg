{ config, pkgs, lib, ... }:
let
  cfg = config.oxc.github;
in {
  options = {
    enable = lib.mkEnableOption "GitHub integrations";

    cli.enable = lib.mkEnableOption "Enable GitHub CLI";
    cli.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.gh;
      description = "GitHub CLI package";
    };

    dash.enable = lib.mkEnableOption "Enable GitHub Dash";
    dash.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.gh-dash;
      description = "GitHub Dash package";
    };
    dash.config = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "GitHub Dash configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = []
      ++ lib.optional cfg.cli.enable cfg.cli.package
      ++ lib.optional cfg.dash.enable cfg.dash.package
      ;

      # TODO: Implement config file generation
  };
}
