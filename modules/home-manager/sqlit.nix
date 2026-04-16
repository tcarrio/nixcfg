{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.sqlit;
in
{
  options.oxc.sqlit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the sqlit SQL TUI";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.sqlit-tui;
      description = "The package to utilize for the sqlit SQL TUI";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}