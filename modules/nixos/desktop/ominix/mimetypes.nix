# see install/mimetypes.sh
{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    xdg.mime.enable = true;

    # TODO: Support for custom mapping of various applications to mime types
    # FOR NOW, you can simply set whatever you need in your Nix config
  };
}
