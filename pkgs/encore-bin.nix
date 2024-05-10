{ lib
, autoPatchelfHook
, cpio
, freetype
, zlib
, openssl
, fetchurl
, gcc-unwrapped
, libjpeg8
, libpng
, fontconfig
, stdenv
, xar
, xorg
}:

let
  version = "1.36.4";

  target_configs = {
    "aarch64-darwin" = {
      checksum = "sha256-3n1ViAgalYJuPwY0k+KIJd+Uw4BgkLLZ2VFxqN31Eq8=";
      platform = "darwin";
      arch = "arm64";
    };
    "x86_64-darwin" = {
      checksum = "sha256-bQbJ55Mk5n18HV+Rcol6NJAYrmWqSILkac6NtdH+caE=";
      platform = "darwin";
      arch = "amd64";
    };
    "aarch64-linux" = {
      checksum = "sha256-MJPfhqtiybI79hDeTbTP8XXzq088zQUyc2kzOj6foUc=";
      platform = "linux";
      arch = "arm64";
    };
    "x86_64-linux" = {
      dlChecksum = "sha256-2aGx8Br2A4v+tBn3ub/43si6mGFEuJVKNazwLyG7rTw=";
      dlPlatform = "linux";
      dlArch = "amd64";
    };
  };

  platform = if stdenv.hostPlatform.isLinux then "linux" else "darwin";
  arch = if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64";

  inherit (target_configs."${arch}-${platform}") dlChecksum dlPlatform dlArch;

  # darwinAttrs = rec {
  #   version = release_version;
  #   src = fetchurl {
  #     url = "https://d2f391esomvqpi.cloudfront.net/encore-${version}-${platform}_${arch}.tar.gz";
  #     sha256 = checksums.darwin.${arch};
  #   };

  #   nativeBuildInputs = [ xar cpio ];

  #   unpackPhase = ''
  #     xar -xf $src
  #     zcat Payload | cpio -i
  #     tar -xf usr/local/share/wkhtmltox-installer/wkhtmltox.tar.gz
  #   '';

  #   installPhase = ''
  #     runHook preInstall
  #     mkdir -p $out
  #     cp -r bin include lib share $out/
  #     runHook postInstall
  #   '';
  # };

  # linuxAttrs = rec {
  #   version = "0.12.6-3";
  #   src = fetchurl {
  #     url = "https://github.com/encoredev/packaging/releases/download/${version}/wkhtmltox-${version}.archlinux-x86_64.pkg.tar.xz";
  #     sha256 = "sha256-6Ewu8sPRbqvYWj27mBlQYpEN+mb+vKT46ljrdEUxckI=";
  #   };

  #   nativeBuildInputs = [ autoPatchelfHook ];

  #   buildInputs = [
  #     xorg.libXext
  #     xorg.libXrender

  #     freetype
  #     openssl
  #     zlib

  #     (lib.getLib fontconfig)
  #     (lib.getLib gcc-unwrapped)
  #     (lib.getLib libjpeg8)
  #     (lib.getLib libpng)
  #   ];

  #   unpackPhase = "tar -xf $src";

  #   installPhase = ''
  #     runHook preInstall
  #     mkdir -p $out
  #     cp -r usr/bin usr/include usr/lib usr/share $out/
  #     runHook postInstall
  #   '';
  # };
in
stdenv.mkDerivation ({
  pname = "encore-bin";

  dontStrip = true;

  version = version;
  src = fetchurl {
    url = "https://d2f391esomvqpi.cloudfront.net/encore-${version}-${dlPlatform}_${dlArch}.tar.gz";
    sha256 = dlChecksum;
  };

  nativeBuildInputs = [ xar cpio ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin $out/
    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    echo "CHECKING INSTALL"
    ls -al $out/bin
    $out/bin/encore --version
  '';

  meta = with lib; {
    homepage = "https://encore.dev/";
    description =
      "The Backend Development Platform purpose-built to help you create event-driven and distributed systems.";
    longDescription = ''
      Cloud services enable us to build highly scalable applications, but often lead to a poor developer
      experience — forcing developers to manage significant complexity during development and do a lot
      of repetitive manual work.

      Encore is purpose-built to solve this problem and provides a complete toolset for backend
      development — from local development and testing, to cloud infrastructure management and DevOps.
    '';
    license = licenses.mpl20;
    maintainers = with maintainers; [ tcarrio ];
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
  };
}
# // lib.optionalAttrs (stdenv.hostPlatform.isDarwin) darwinAttrs
# // lib.optionalAttrs (stdenv.hostPlatform.isLinux) linuxAttrs
)