# see install/bluetooth.sh
{ config, lib, pkgs, ... }:
let
  cfg = config.ominix;
in
{
  config = lib.mkIf (cfg.enable && cfg.bluetooth.enable) {
    environment.systemPackages = with pkgs; [
      blueberry
    ];

    # TODO: Make configurable
    hardware.bluetooth = {
      enable = true;
      # powerOnBoot = true;
    };
  };

}
