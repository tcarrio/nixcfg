{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.oxc.github;
in
{
  imports = [ ./gh-dash ];

  options.oxc.github = {
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
      default = { };
      description = "GitHub Dash configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gh = lib.mkIf cfg.cli.enable {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "${pkgs.nixvim}/bin/nvim";
        host = "github.com";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
