{ config, pkgs, lib, ... }: {
  options.oxc.services.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Tailscale mesh network service";
    };
  };

  config = lib.mkIf (config.oxc.services.tailscale.enable && !config.oxc.services.tailscale.autoconnect) {
    # tailscale CLI
    environment.systemPackages = [ pkgs.tailscale ];

    # tailscale service
    services.tailscale.enable = true;

    # firewall integration
    networking = {
      firewall = {
        checkReversePath = "loose";
        allowedUDPPorts = [ config.services.tailscale.port ];
        trustedInterfaces = [ "tailscale0" ];
      };
    };
  };
}
