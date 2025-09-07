{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.ominix;
  inherit (cfg.hardware) cpu gpu;
  mkOminixDefault = value: lib.mkOverride 999 value;
in
with lib; with types; {
  options.ominix = {
    enable = mkOption {
      type = bool;
      description = """
        Whether to enable the Ominix module. Powered by the Omarchy project.
        See https://omarchy.org/.
      """;
    };

    user = mkOption {
      type = nullOr str;
      description = "The end-user's username";
    };

    # Hardware configurations
    hardware = {
      cpu = {
        amd = mkOption {
          type = bool;
          description = """
            Whether to enable the AMD CPU support in Ominix.
          """;
        };
        intel = mkOption {
          type = bool;
          description = """
            Whether to enable the Intel CPU support in Ominix.
          """;
        };
      };
      gpu = {
        amd = mkOption {
          type = bool;
          description = """
            Whether to enable the AMD GPU support in Ominix.
          """;
        };
        intel = mkOption {
          type = bool;
          description = """
            Whether to enable the Intel GPU support in Ominix.
          """;
        };
        nvidia = mkOption {
          type = bool;
          description = """
            Whether to enable the Nvidia GPU support in Ominix.
          """;
        };
      };
    };

    battery.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable battery support";
    };
    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Bluetooth connectivity support";
    };
    wireless.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable wireless networking support (WiFi)";
    };

    warnings = []
      ++ optional (cfg.enable && (cpu.amd || cpu.intel))
        "A CPU has not been configured for Ominix!"
      ++ optional (cfg.enable && (gpu.amd || gpu.intel || gpu.nvidia))
        "A GPU has not been configured for Ominix!";

    assertions = [
      {
        assertion = cfg.enable && cfg.user != null && builtins.stringLength cfg.user > 0;
        message = "An unprovided or empty user value was detected";
      }
    ];
  };

  imports = [
    # shared functions exported under lib.ominix
    # ./lib.nix

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

  config.ominix = {
    enable = mkOminixDefault false;
    user = mkOminixDefault null;
    hardware = {
      cpu = {
        amd = mkOminixDefault false;
        intel = mkOminixDefault false;
      };
      gpu = {
        amd = mkOminixDefault false;
        intel = mkOminixDefault false;
        nvidia = mkOminixDefault false;
      };
    };
  };
}
