{ lib, config, pkgs, ... }:
{
  options.oxc.desktop.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Discord chat application";
    };

    krisp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable the Krisp noise cancelling";
    };
  };

  config = lib.mkIf config.oxc.desktop.discord.enable {
    environment.systemPackages =
      if config.oxc.desktop.discord.krisp
      then [ pkgs.discord-krisp ]
      else [ pkgs.discord ];
  };
}
