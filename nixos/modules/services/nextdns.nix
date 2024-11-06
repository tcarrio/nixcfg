{ pkgs, lib, config, ... }: {
  options.oxc.services.nextdns = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for nextdns";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "ecefa7";
      description = "Set the profile ID to use for the hosted NextDNS service";
    };
  };

  config = lib.mkIf config.oxc.services.nextdns.enable {
    environment.systemPackages = with pkgs; [
      nextdns
    ];
    services.nextdns = {
      enable = true;
      arguments = [ "-profile" config.oxc.services.nextdns.profile "-cache-size" "10MB" "-report-client-info" "-auto-activate" ];
    };
  };
}
