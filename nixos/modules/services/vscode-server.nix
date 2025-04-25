{ lib, config, inputs, ... }:
let
  cfg = config.oxc.desktop.vscode.server;
in {
  options.oxc.desktop.vscode.server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Visual Studio Code Server service.";
    };
  };

  imports = lib.optional cfg.enable [
    inputs.vscode-server.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    services.vscode-server.enable = true;
  };
}
