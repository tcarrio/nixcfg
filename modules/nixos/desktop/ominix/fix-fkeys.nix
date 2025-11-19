# see install/fix-fkeys.sh
{ config, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.etc."modprobe.d/hid_apple.conf".text = "options hid_apple fnmode=2";
  };
}
