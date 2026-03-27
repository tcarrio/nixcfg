{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellScriptBin "uri-decode" ''
  #!${pkgs.bash}/bin/bash
  set -e

  input="$@"
  if [ $# -eq 0 ]; then
    input=$(cat)
  fi

  # Thanks http://stackoverflow.com/questions/6250698/ddg#37840948
  function urldecode() { : "''${*//+/ }"; echo -e "''${_//%/\\x}"; }

  urldecode "$input"
''
