{ lib, config, inputs, ... }: {
  options.oxc.desktop.vscode.server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Visual Studio Code Server service.";
    };
  };

  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  config = lib.mkIf config.oxc.desktop.vscode.server.enable {
    services.vscode-server.enable = true;
  };
}
