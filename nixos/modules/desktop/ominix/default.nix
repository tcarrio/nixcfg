{ config, pkgs, lib, inputs, ... }: {

  options.ominix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = """
        Whether to enable the Ominix module. Powered by the Omarchy project.
        See https://omarchy.org/.
      """;
    };
  };

  imports = [
    ./bluetooth.nix
    ./desktop.nix
    ./development.nix
    ./docker.nix
    ./fix-fkeys.sh
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
