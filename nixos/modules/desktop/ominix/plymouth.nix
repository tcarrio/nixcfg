# see install/plymouth.sh
{ config, ... }: {
  config = lib.mkIf config.ominix.enable {
    boot.plymouth.enable = true;

    # TODO: Support theme
    # Likely requires making a package derivation from the source tree
    # Nixpkgs reference for a theme can be found here:
    # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/pl/plymouth-matrix-theme/package.nix#L37

    # TODO: Support extended boot configurations
  };
}
