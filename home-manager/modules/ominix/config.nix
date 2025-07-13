# see install/themes.sh
{ config, pkgs, lib, inputs, username, ... }:
let
  cfg = config.ominix;
in
{
  config = lib.mkIf cfg.enable (
    let
      omarchyDirPath = "${inputs.omarchy}";
      configDirPath = "${inputs.omarchy}/config";

      allConfigFiles = map builtins.unsafeDiscardStringContext (lib.filesystem.listFilesRecursive configDirPath);

      mapToRelativePath = root: path: lib.removePrefix (toString root) (toString path);
      mapToRootRelativePath = mapToRelativePath "${omarchyDirPath}/";
      mapToConfigRelativePath = mapToRelativePath "${configDirPath}/";
    in {
      # home.file.".config/btop/btop.conf".source = "${configDirPath}/btop/btop.conf";
      home.file = lib.listToAttrs (map (path:
        let
          relativePath = mapToConfigRelativePath path;
        in {
          name = ".config/${relativePath}";
          value = {
            source = lib.mkDefault "${configDirPath}/${relativePath}";
          };
        }
      ) allConfigFiles);
    }
  );
}

