# see install/network.sh
{ config, lib, ... }:
let
  cfg = config.ominix;
in
{
  config = lib.mkIf (cfg.enable && cfg.wireless.enable) {
    # TODO: iwd or nm?
    # networking.wireless.iwd.enable = true;
    # networking.networkmanager.wifi.backend = "iwd";
  };
}
