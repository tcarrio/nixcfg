{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.neovim;
in
{
  options.oxc.console.neovim = {
    enable = lib.mkEnableOption "neovim via the oxc nixvim package";

    # The default is the flake's own wrapped nixvim (additions overlay);
    # external consumers supply their own package here.
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nixvim;
      defaultText = lib.literalExpression "pkgs.nixvim (additions overlay)";
      description = "The neovim distribution to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
    };
  };
}
