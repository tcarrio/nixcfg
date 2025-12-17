{ config, lib, pkgs, ... }:
let
  cfg = config.oxc.podman;

  inherit (pkgs) podman;

  dockerCompat = pkgs.runCommand "${podman.pname}-docker-compat-${podman.version}"
    {
      outputs = [
        "out"
        "man"
      ];
      inherit (podman) meta;
      preferLocalBuild = true;
    }
    ''
      mkdir -p $out/bin
      ln -s ${podman}/bin/podman $out/bin/docker

      mkdir -p $man/share/man/man1
      for f in ${podman.man}/share/man/man1/*; do
        basename=$(basename $f | sed s/podman/docker/g)
        ln -s $f $man/share/man/man1/$basename
      done
    '';
in
{
  options.oxc.podman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Podman support";
    };
    desktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Podman Desktop support";
    };
  };

  config = lib.mkIf cfg.enable
    {
      environment.systemPackages = with pkgs; [
        podman
        podman-compose
        podman-tui
        dockerCompat
      ];
    } // lib.mkIf (cfg.enable && cfg.desktop.enable) {
    homebrew.casks = [ "podman-desktop" ];
  };
}
