# see install/themes.sh
{ config, pkgs, lib, inputs, username, ... }:
let
  cfg = config.ominix;
in
{
  config = lib.mkIf cfg.enable (
    let
      themeDir = "${inputs.omarchy}/config";
      configDirContents = builtins.readDir themeDir;
    in {
      home.file = lib.attrsets.genAttrs configDirContents (name: {
        "${name}".source = "${themeDir}/${name}";
      });
    }
  );
}

