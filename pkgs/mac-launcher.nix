{ pkgs ? import <nixpkgs> { }, lib }:

pkgs.stdenv.mkDerivation rec {
  pname = "mac-launcher";
  version = "1.0.0";

  src = ./.;

  buildInputs = with pkgs; [
    choose
  ];

  buildPhase = ''
    cat > ${pname} << 'EOF'
    #!/bin/bash

    # Find all .app bundles in common macOS application directories
    ls /Applications/ '/Applications/Nix Apps' /Applications/Utilities/ /System/Applications/ /System/Applications/Utilities/ 2>/dev/null | \
        grep '\.app$' | \
        sed 's/\.app$//g' | \
        ${pkgs.choose-gui}/bin/choose | \
        xargs -I {} open -a "{}.app"
    EOF

    chmod +x ${pname}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';

  meta = with lib; {
    description = "Interactive macOS application launcher";
    longDescription = ''
      A shell script that scans common macOS application directories,
      presents a list of available applications using 'choose',
      and opens the selected application.
    '';
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = [ maintainers.tcarrio ];
  };
}

