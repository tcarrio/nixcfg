{ pkgs, ... }: {
  home.file.".config/nvim/init.lua".text = builtins.readFile ./neovim/init.lua;

  home.packages = with pkgs; [
    neovim
    nnn
    zig
  ];
}
