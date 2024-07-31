{ lib, config, ... }: {
  options.oxc.nix.unfree = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Allow unfree packages to be installed";
    };
  };

  config.nixpkgs.config.allowUnfree = config.oxc.nix.unfree.enable;
}
