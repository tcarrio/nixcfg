{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.asciinema;
in
{
  options.oxc.console.asciinema = {
    enable = lib.mkEnableOption "asciinema terminal recording (asciinema + agg)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      asciinema
      asciinema-agg
    ];
  };
}
