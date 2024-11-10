{ lib, config, ... }:
let
  cfg = config.oxc.services.remote-builder;
  glass = {
    hostName = "glass";
    system = "x86_64-linux";
    ### To enable multi-architecture builds when the host supports it
    # systems = ["x86_64-linux" "aarch64-linux"];
    protocol = "ssh-ng";
    maxJobs = 8;
    speedFactor = 4;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  };
in {
  options.oxc.services.remote-builder = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Support for remote nix builders";
    };
    hosts.glass = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Support for remote nix builders";
      };
      local = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Inject a hosts file override to the private local network address";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = [] ++ (lib.optional cfg.hosts.glass.enable glass);
    ### optional, useful when the builder has a faster internet connection than yours
    # nix.extraOptions = ''
    #   builders-use-substitutes = true
    # '';
  };
}