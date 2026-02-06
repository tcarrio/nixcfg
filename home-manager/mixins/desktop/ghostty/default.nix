{ config, inputs, pkgs, lib, systemType, ... }:
let
  isLinux = systemType == "linux";
in
{
  home = {
    file = {
      "${config.xdg.configHome}/ghostty/themes".source = "${inputs.ghostty-catppuccin}/themes";
    };
  };

  programs.ghostty = {
    enable = true;

    settings = {
      font-family = "Ubuntu Mono derivative Powerline";
      font-size = 14;

      # Theming
      theme = "Catppuccin Mocha";
    } // (if !isLinux then {
      # Use the latest nightly builds
      auto-update-channel = "tip";
    } else { });
  } // lib.mkIf isLinux {
    # Enable Nix management of Ghostty package on Linux only
    package = pkgs.ghostty;
  };
}
