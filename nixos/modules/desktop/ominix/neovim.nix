# see install/neovim.sh
{ config, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # TODO: Support for LazyVim starter?
    # https://github.com/LazyVim/starter
  };
}
