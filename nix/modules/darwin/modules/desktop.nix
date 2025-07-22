{ lib, config, pkgs, username, ... }: {
  options.oxc.desktop.applications = {
    enable = lib.mkOption {
      default = true;
      description = "Whether to enable desktop application support in Darwin";
    };
  };

  # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
  config = lib.mkIf config.oxc.desktop.applications.enable {
    system.activationScripts.SyncNixApplications.text = ''
      declare -a rsyncArgs=("--archive" "--checksum" "--chmod=-w" "--copy-unsafe-links" "--delete")
      apps_source="${config.system.build.applications}/Applications"
      moniker="Nix Trampolines"
      app_target_base="/Users/${username}/Applications"
      app_target="$app_target_base/$moniker"
      mkdir -p "$app_target"
      ${pkgs.rsync}/bin/rsync "''${rsyncArgs[@]}" "$apps_source/" "$app_target"
    '';
  };
}
