{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.harlequin;
in
{
  options.oxc.harlequin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Harlequin SQL TUI";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.harlequin;
      description = "The package to utilize for the Harlequin SQL TUI";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}