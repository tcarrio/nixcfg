{ config, lib, pkgs, ... }: {
  options.oxc.services.nextdns = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the NextDNS service";
    };
    id = lib.mkOption {
      type = lib.types.string;
      default = "ecefa7";
      description = "The identifier for the NextDNS profile to utilize";
    };
  };

  config = lib.mkIf config.oxc.services.nextdns.enable {
    environment.systemPackages = with pkgs; [
      nextdns
    ];

    services.nextdns = {
      enable = true;
      arguments = ["-profile" "${config.oxc.services.nextdns.id}" "-report-client-info" "-auto-activate"];
    };
  };
}
