{ config, lib, ... }: {
  options.oxc.services.nordvpn = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the NordVPN service";
    };

    firewall = {
      open = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports for the NordVPN service access";
      };
    };
  };

  config = lib.mkIf config.oxc.services.nordvpn.enable {
    chaotic.nordvpn.enable = true;

    networking.firewall = if !config.oxc.services.nordvpn.firewall.open then {} else {
      allowedTCPPorts = [ 443 ];
      allowedUDPPorts = [ 1194 ];
    };
  };
}
