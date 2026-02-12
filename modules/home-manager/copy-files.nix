{ config, lib, pkgs, ... }:
let
  copyFilesScriptForPathEntry = path: entry:
    let
      pathParts = lib.strings.splitString "/" path;
      fileName = lib.lists.last pathParts;
      dirPath = lib.strings.join "/" (lib.lists.init pathParts);
      src = if (entry ? source && entry.source != null)
        then entry.source
        else (
          if (entry ? text && entry.text != null)
            then
              pkgs.writeText "${fileName}" entry.text
            else throw "Missing source and text from copy-files option ${path}"
        );
    in pkgs.writeShellScript "apply-copy-files" ''
      set -eou pipefail

      target_file="$HOME/${path}"

      # Ensure the nested directories exist for the target file
      target_dir="$HOME/${dirPath}"
      if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
      fi

      cat "${src}" > "$target_file"
    '';

  mapFileOptionToActivationScript = name: value:
    let
      copyScript = copyFilesScriptForPathEntry name value;
    in lib.nameValuePair
      "activation-copy-files-to-${name}"
      (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${copyScript}
      '');


  cfg = config.home.copy-files;
in
{
  options.home.copy-files = with lib; mkOption {
    default = {};
    description = "A utility module for copying Nix-defined files to a target path relative to the user's home directory";
    type = with types; attrsOf (submodule {
      options = {
        text = mkOption {
          type = nullOr str;
          default = null;
        };
        source = mkOption {
          type = nullOr path;
          default = null;
        };
      };
    });
  };

  config = lib.mkIf ((builtins.length (lib.attrNames cfg)) > 0) {
    home.activation = lib.attrsets.mapAttrs' mapFileOptionToActivationScript cfg;
  };
}
