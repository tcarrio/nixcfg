{ lib, ... }: {
  options.oxc.tailnet = {
    dns = lib.mkOption {
      type = lib.types.str;
      default = "100.100.100.100";
      description = "DNS resolver for Tailscale-connected resources";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "griffin-cobra.ts.net";
      description = "Domain name of personal Tailnet";
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = import ../../../lib/tailnet-matrix.nix;
      description = "Tailnet mapping of hostnames to IPv4 addresses";
    };
  };
}
