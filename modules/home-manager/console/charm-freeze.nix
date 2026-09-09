{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.charm-freeze;
in
{
  options.oxc.console.charm-freeze = {
    enable = lib.mkEnableOption "charm-freeze code screenshot tool with the oxc theme";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ charm-freeze ];

    home.file.".config/freeze/custom.json".text = builtins.readFile ./charm-freeze/config.json;

    # Alias routes through the managed config; guarded on the fish module
    # owning the shell rather than writing programs.fish directly.
    oxc.console.fish.aliases = lib.mkIf config.oxc.console.fish.enable {
      frz = "${pkgs.charm-freeze}/bin/freeze -c $HOME/.config/freeze/custom.json";
    };
  };
}
