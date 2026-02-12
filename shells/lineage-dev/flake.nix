{
  description = "An Android development shell focused on LineageOS build support";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs
    , flake-utils
    , ...
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "python-2.7.18.12"
          ];
        };
      };
    in
    {
      devShells.default = let
        # Derived from https://gist.github.com/Nadrieril/d006c0d9784ba7eff0b092796d78eb2a
        fhs = pkgs.buildFHSEnv {
          name = "android-env";
          targetPkgs = pkgs: with pkgs; [
            androidenv.androidPkgs.platform-tools
            bc
            binutils
            bison
            ccache
            curl
            flex
            gcc
            git
            gitRepo
            gnumake
            gnupg
            gperf
            imagemagick
            jdk11_headless # was jdk7
            libxml2
            lz4
            lzop
            m4
            maven # Needed for LineageOS 13.0
            nettools
            openssl
            perl
            pngcrush
            procps
            python2
            rsync
            schedtool
            SDL
            squashfsTools
            unzip
            utillinux
            wxGTK31 # was wxGTK30
            xml2
            zip
          ];
          multiPkgs = pkgs: with pkgs; [
            zlib
            ncurses5
            libcxx
            readline
          ];
          runScript = "bash";
          profile = ''
            export USE_CCACHE=1
            export ANDROID_JAVA_HOME=${pkgs.jdk11_headless.home}
            # Building involves a phase of unzipping large files into a temporary directory
            export TMPDIR=/tmp
          '';
        };

      in pkgs.stdenv.mkDerivation {
        name = "android-env-shell";
        nativeBuildInputs = [ fhs ];
        shellHook = ''

          echo "
            >>> EXAMPLE STEPS
            $ repo init -u https://github.com/LineageOS/android.git -b cm-13.0
            $ repo sync
            $ source build/envsetup.sh
            $ breakfast maguro
            Get proprietary blobs (see https://wiki.lineageos.org/devices/maguro/build#extract-proprietary-blobs)
             (I actually used blobs from https://github.com/TheMuppets, following https://forum.xda-developers.com/showpost.php?s=a6ee98b07b1b0a2f4004b902a65d9dcd&p=76981184&postcount=4)
            $ ccache -M 50G (see https://wiki.lineageos.org/devices/maguro/build#turn-on-caching-to-speed-up-build)
            $ croot
            $ brunch maguro
            $ cd $OUT
          "
          exec android-env
        '';
      };


      # Nix formatter

      # This applies the formatter that follows RFC 166, which defines a standard format:
      # https://github.com/NixOS/rfcs/pull/166

      # To format all Nix files:
      # git ls-files -z '*.nix' | xargs -0 -r nix fmt
      # To check formatting:
      # git ls-files -z '*.nix' | xargs -0 -r nix develop --command nixfmt --check
      formatter = pkgs.nixfmt-rfc-style;
    });
}
