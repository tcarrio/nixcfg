{ lib, config, pkgs, ... }:
{
  options.oxc.desktop.discord = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Discord chat application";
    };

    krisp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the Krisp noise cancelling";
      };
    };
  };

  config = lib.mkIf config.oxc.desktop.discord.enable {
    environment.systemPackages = with pkgs.unstable; if config.oxc.desktop.discord.krisp then [
      discord-krisp
    ] else [ discord ];
  };
}
