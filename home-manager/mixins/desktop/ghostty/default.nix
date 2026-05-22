{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  linuxOptions = lib.mkIf isLinux {
    # Enable Nix management of Ghostty package on Linux only
    package = pkgs.unstable.ghostty;
  };
  darwinOptions = lib.mkIf isDarwin {
    package = pkgs.empty;
    settings = {
      # Use the latest nightly builds
      auto-update-channel = "tip";
    };
  };
in
{
  home = {
    file = {
      "${config.xdg.configHome}/ghostty/themes".source = "${inputs.ghostty-catppuccin}/themes";
    };
  };

  programs.ghostty = lib.mkMerge [
    {
      enable = true;

      settings = {
        font-family = "Ubuntu Mono derivative Powerline";
        font-size = 14;

        # Theming
        theme = "Catppuccin Mocha";
      };
    }
    linuxOptions
    darwinOptions
  ];
}
