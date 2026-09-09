{ lib, ... }:
{
  options.oxc.tailnet = {
    dns = lib.mkOption {
      type = lib.types.str;
      default = "100.100.100.100";
      description = "DNS resolver for Tailscale-connected resources";
    };
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Domain name of the Tailnet. Neutral by default — hosts that want
        it set it explicitly (internal hosts from their tailnet matrix).
      '';
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Tailnet mapping of hostnames to IPv4 addresses. Neutral by
        default — internal hosts set it from lib/tailnet-matrix.nix.
      '';
    };
  };
}
