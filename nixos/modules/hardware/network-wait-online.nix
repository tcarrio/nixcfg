{ lib, config, ... }: {
  options.oxc.services.wait-online = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the wait-online service";
    };
  };

  config = lib.mkIf (!config.oxc.services.wait-online.enable) {
    systemd.services = {
      NetworkManager-wait-online.enable = lib.mkForce false;
      systemd-networkd-wait-online.enable = lib.mkForce false;
    };
  };
}
