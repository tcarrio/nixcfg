{ lib, config, pkgs, ... }: {
  options.oxc.desktop.daw = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the digital audio workstation tools";
    };
  };

  config = lib.mkIf config.oxc.desktop.daw.enable {
    environment.systemPackages = with pkgs; [
      ardour
      hydrogen
      tenacity
    ];
  };
}
