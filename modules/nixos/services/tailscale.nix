{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.oxc.services.tailscale;

  # Determine which service to depend on

  # User to run as - defaults to tailscale
in
{
  options.oxc.services.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Tailscale mesh network service";
    };

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the Tailscale SSH override for Tailnet hosts";
      };
    };

    exitNode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow the Tailscale service to serve as an exit node";
      };
    };

    services = lib.mkOption {
      type = lib.types.listOf lib.types.submodule;
      default = [ ];
      description = "The list of services to expose on the Tailnet from this host";
    };
  };

  config = lib.mkIf cfg.enable {
    # tailscale CLI
    environment.systemPackages = [ pkgs.tailscale ];

    # tailscale service

    services.tailscale = {
      enable = true;
      extraSetFlags = lib.optionals cfg.exitNode.enable [ "--advertise-exit-node" ];
      extraUpFlags = lib.optionals cfg.ssh.enable [ "--ssh" ];
    };

    # tailscale serve units
    # TODO: fix building of systemd service units
    # systemd.services = systemdUnits;

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
