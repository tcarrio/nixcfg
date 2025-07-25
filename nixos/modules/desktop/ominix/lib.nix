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

  # Provides behavior like lib.mkDefault but overrides default configurations.
  # When settings values that are intended to override defaults set in Ominix,
  # you MUST either set the value (which has an implicit priority of 100) or
  # use mkOverride with a value < 999.
  lib.mkOminixDefault = value: lib.mkOverride 999 value;
}

