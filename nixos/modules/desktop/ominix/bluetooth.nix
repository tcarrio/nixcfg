# see install/bluetooth.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
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