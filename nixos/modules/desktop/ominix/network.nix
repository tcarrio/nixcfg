# see install/network.sh
{ config, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
