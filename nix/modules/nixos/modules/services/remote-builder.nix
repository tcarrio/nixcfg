{ lib, config, ... }:
let
  cfg = config.oxc.services.remote-builder;

  hosts.glass = {
    # The system MUST be connected over Tailscale
    hostName = if cfg.hosts.glass.local then "192.168.40.72" else "glass";
    sshUser = "grigori";
    system = "x86_64-linux";
    ### To enable multi-architecture builds when the host supports it
    # systems = ["x86_64-linux" "aarch64-linux"];
    protocol = "ssh-ng";
    maxJobs = 16;
    speedFactor = 8;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  };
in
{
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
    nix.buildMachines = lib.optional cfg.hosts.glass.enable hosts.glass;
    ## optional, useful when the builder has a faster internet connection than yours
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
