{ pkgs, ... }:
let
  podman = pkgs.podman;

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
in {
  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    podman-tui
    dockerCompat
  ];
}

