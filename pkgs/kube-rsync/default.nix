{ pkgs, ... }:

let
  pname = "kube-rsync";
  runtimePkgs = with pkgs; [ kubectl rsync ];
  kubeRsyncPkg = (pkgs.writeScriptBin pname (builtins.readFile ./kube-rsync.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in
pkgs.symlinkJoin {
  name = pname;
  paths = [ kubeRsyncPkg ] ++ runtimePkgs;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${pname} --prefix PATH : $out/bin";
}
