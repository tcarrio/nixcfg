{ lib, config, ... }: {
  options.oxc.services.wait-online = {
    disable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable the wait-online service";
    };
  };

  config = lib.mkIf config.oxc.services.wait-online.disable {
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  };
}
