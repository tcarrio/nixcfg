{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.ominix;
  inherit (cfg.hardware) cpu gpu;
in {

  options.ominix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = """
        Whether to enable the Ominix module. Powered by the Omarchy project.
        See https://omarchy.org/.
      """;
    };

    user = lib.mkOption {
      type = lib.types.string;
      description = "The end-user's username";
    };

    # Hardware configurations
    hardware = {
      cpu = {
        amd = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = """
            Whether to enable the AMD CPU support in Ominix.
          """;
        };
        intel = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = """
            Whether to enable the Intel CPU support in Ominix.
          """;
        };
      };
      gpu = {
        amd = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = """
            Whether to enable the AMD GPU support in Ominix.
          """;
        };
        intel = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = """
            Whether to enable the Intel GPU support in Ominix.
          """;
        };
        nvidia = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = """
            Whether to enable the Nvidia GPU support in Ominix.
          """;
        };
      };
    };

    warnings = []
      ++ lib.optional (cpu.amd || cpu.intel)
        "A CPU has not been configured for Ominix!"
      ++ lib.optional (gpu.amd || gpu.intel || gpu.nvidia)
        "A GPU has not been configured for Ominix!";

    assertions = [
      {
        assertion = builtins.stringLength cfg.user == 0;
        message = "An unprovided or empty user value was detected";
      }
    ];
  };

  imports = [
    # shared functions exported under lib.ominix
    ./lib.nix

    ./autologin.nix
    ./bluetooth.nix
    ./desktop.nix
    ./development.nix
    ./docker.nix
    ./fix-fkeys.nix
    ./fonts.nix
    ./hyprlandia.nix
    ./mimetypes.nix
    ./network.nix
    ./neovim.nix
    ./nvidia.nix
    ./plymouth.nix
    ./power.nix
    ./printer.nix
    ./ruby.nix
    ./terminal.nix
    ./themes.nix
    ./xtras.nix
  ];
}
