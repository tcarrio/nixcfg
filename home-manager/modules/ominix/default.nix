{ config, pkgs, lib, inputs, ... }: {
  options.omnixy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = """
        Whether to enable the Omnixy module. Powered by the Omarchy project.
        See https://omarchy.org/.
      """;
    };
  };

  imports = [
    ./themes.nix
  ];
}
