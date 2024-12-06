{ config, lib, pkgs, ... }: {
  # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
  home.activation = {
    rsync-home-manager-applications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      declare -a rsyncArgs=("--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--delete")
      apps_source="$genProfilePath/home-path/Applications"
      moniker="Home Manager Trampolines"
      app_target_base="${config.home.homeDirectory}/Applications"
      app_target="$app_target_base/$moniker"
      mkdir -p "$app_target"
      ${pkgs.rsync}/bin/rsync "''${rsyncArgs[@]}" "$apps_source/" "$app_target"
    '';
  };
}
