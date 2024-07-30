{ lib, config, inputs, ... }: {
  options.oxc.services.vscode-server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Visual Studio Code Server service.";
    };
  };

  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  services.vscode-server.enable = config.oxc.services.vscode-server.enable;
}
