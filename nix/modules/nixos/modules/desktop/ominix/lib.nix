{ lib, pkgs, ... }: {
  lib.ominix.wrapShellScript = attrs: let
    inherit (attrs) name buildInputs filePath;
    wrappedScript = (pkgs.writeScriptBin name (builtins.readFile filePath))
      .overrideAttrs(old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      });
  in pkgs.symlinkJoin {
    inherit (attrs) name;
    paths = [ wrappedScript ] ++ buildInputs;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
  };
}

