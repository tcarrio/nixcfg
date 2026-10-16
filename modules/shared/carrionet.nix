{ lib, ... }:
{
  options.oxc.carrionet = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = import ../../lib/carrionet-matrix.nix;
      description = ''
        Home network (carrionet) mapping of hostnames to reserved IPv4
        addresses. First address is the primary. Defaults to
        lib/carrionet-matrix.nix; hosts may override or extend per-system.
      '';
    };
  };
}
