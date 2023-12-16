{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  nordvpn = stdenv.mkDerivation {
      name = "nordvpn";

      src = fetchurl {
        url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_3.16.9_amd64.deb";
        sha256 = "40b87fe0aabc2ef7197dce6780bbb0ec1380a98ae8ca45252b6c72dccd2b0e4c";
      };

      nativeBuildInputs = [ dpkg libxml2 ];

      phases = [ "unpackPhase" "installPhase" "fixupPhase" "postFixupPhase" "distPhase" ];

      unpackPhase = "dpkg -x $src unpacked";

      installPhase = ''
        mkdir -p $out/usr
        cp -r unpacked/* $out/
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/usr/bin/nordvpn
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/usr/sbin/nordvpnd
      '';

      postFixup = ''
        wrapProgram $out/usr/sbin/nordvpnd --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.libxml2 ]}
      '';

      dontPatchShebangs = true;
      dontStrip = true;
      dontPatchELF = true;
      dontAutoPatchelf = true;

  };
in pkgs.buildFHSUserEnvBubblewrap {
  name = "nordvpnd";
  targetPkgs = pkgs: [ nordvpn ];
  runScript = "${nordvpn}/usr/sbin/nordvpnd";
}