{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.services.mpris-proxy;
in
{
  options.oxc.services.mpris-proxy = {
    enable = lib.mkEnableOption "the mpris-proxy Bluetooth media service";
  };

  config = lib.mkIf cfg.enable {
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    services.mpris-proxy.enable = true;
  };
}
