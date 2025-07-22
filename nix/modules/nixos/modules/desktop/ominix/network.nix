# see install/network.sh
{ config, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    # TODO: iwd or nm?
    # networking.wireless.iwd.enable = true;
    # networking.networkmanager.wifi.backend = "iwd";
  };
}
