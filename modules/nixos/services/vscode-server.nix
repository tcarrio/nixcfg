{
  lib,
  config,
  ...
}:
{
  options.oxc.desktop.vscode.server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Visual Studio Code Server service.";
    };
  };

  # NOTE: the upstream nixos-vscode-server module must be imported by the
  # caller (internal hosts: mkHost wires inputs.vscode-server via the
  # workstation host files). This module only drives its options.
  config = lib.mkIf config.oxc.desktop.vscode.server.enable {
    services.vscode-server.enable = true;
  };
}
