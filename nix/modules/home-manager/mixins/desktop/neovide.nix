{ config, pkgs, ... }:
let
  neovim = pkgs.nixvim;
in {
  home.file.".config/neovide/config.toml".text = ''
    # backtraces_path = "/path/to/neovide_backtraces.log"
    fork = false
    frame = "full"
    idle = true
    maximized = true
    mouse-cursor-icon = "arrow"
    neovim-bin = "${neovim}/bin/nvim"
    no-multigrid = false
    srgb = false
    tabs = true
    # theme = "auto"
    title-hidden = true
    vsync = true
    wsl = false

    [font]
    normal = [] # Will use the bundled Fira Code Nerd Font by default
    size = 13.0

    [box-drawing]
    # "font-glyph", "native" or "selected-native"
    mode = "font-glyph"

    [box-drawing.sizes]
    default = [2, 4]  # Thin and thick values respectively, for all sizes
  '';

  home.packages = [
    # neovide is installed at the system-level in /darwin
    pkgs.unstable.neovim
  ];
}
