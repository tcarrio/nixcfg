{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.ominix;
  idCfg = cfg.identification;
  isNonEmptyString = email: (builtins.stringLength email > 0);
  isEmail = isNonEmptyString;
  # TODO: Implement email check
  # isEmail = email: (1 == length (builtins.match("^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,})$" email));
in {
  options.ominix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = """
        Whether to enable the Ominix home-manager module.
      """;
    };
    identification = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = """
          Whether to enable the Ominix identification configurations.

          Provides various utilities for e.g. git.
        """;
      };
      name = lib.mkOption {
        type = lib.types.string;
        default = ""; 
        description = "The user's name";
      };
      email = lib.mkOption {
        type = lib.types.string;
        default = "";
        description = "The user's email address";
      };
      username = lib.mkOption {
        type = lib.types.string;
        default = "";
        description = "The user's username";
      };
    };

    assertions = [
      {
        assertion = idCfg.enable && !(isEmail idCfg.email);
        message = "Email must be valid when identification is enabled";
      }
      {
        assertion = idCfg.enable && !(isNonEmptyString idCfg.name);
        message = "Name must be provided when identification is enabled";
      }
      {
        assertion = idCfg.enable && !(isNonEmptyString idCfg.username);
        message = "Username must be provided when identification is enabled";
      }
    ];
  };

  imports = [
    ./git.nix
    ./themes.nix
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = lib.mkIf idCfg.enable {
      # Using the OMARCHY vars for script compatibility
      OMARCHY_USER_NAME = idCfg.name;
      OMARCHY_USER_EMAIL = idCfg.email;
    };
  };
}
