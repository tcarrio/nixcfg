{ lib, ... }: {
  options.oxc.nix.unfree = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Allow unfree packages to be installed";
    };
  };

  nixpkgs.config.allowUnfree = config.oxc.nix.unfree.enable;
}
