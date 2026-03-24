{ lib, ... }: {
  options.oxc.tailnet.hosts = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = import ../../../lib/tailnet-matrix.nix;
    description = "Tailnet mapping of hostnames to IPv4 addresses";
  };
}
