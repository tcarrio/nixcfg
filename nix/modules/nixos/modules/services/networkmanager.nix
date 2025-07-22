{ config, lib, ... }:
let
  cfg = config.oxc.services.networkmanager;
in
{
  options.oxc.services.networkmanager = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable NetworkManager";
    };

    wireless = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable support for wireless networking with NetworkManager";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi = lib.mkIf cfg.wireless.enable {
          backend = "iwd";
        };
      };
      wireless = lib.mkIf cfg.wireless.enable {
        enable = false;
      };
    };
  };
}
