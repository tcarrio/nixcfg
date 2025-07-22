{ lib, config, pkgs, ... }: {
  options.oxc.desktop.logseq = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Logseq editor";
    };
  };

  config = lib.mkIf config.oxc.desktop.logseq.enable {
    environment.systemPackages = with pkgs; [
      logseq
    ];

    # required due to outdated version of Electron used for Logseq
    nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];
  };
}
