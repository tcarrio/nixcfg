# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev:
    let
      inherit (final.stdenv.hostPlatform) system;
      inherit (import ../lib/bun.nix {}) mkBunDerivation;
      mkStandardBun = mkBunDerivation inputs.bun2nix.packages.${system}.default;

      customPkgs = import ../pkgs {
        pkgs = final;
        inherit (inputs) nixvim;
        inherit mkStandardBun;
      };
    in (
      customPkgs
      //
      rec {
        # Override nixvim to automatically use the current nixpkgs allowUnfree configuration
        mustacheTemplate = name: template: data:
          prev.stdenv.mkDerivation {
            name = "${name}";

            nativeBuildInpts = [ prev.mustache-go ];

            # Pass Json as file to avoid escaping
            passAsFile = [ "jsonData" ];
            jsonData = builtins.toJSON data;

            # Disable phases which are not needed. In particular the unpackPhase will
            # fail, if no src attribute is set
            phases = [ "buildPhase" "installPhase" ];

            buildPhase = ''
              ${prev.mustache-go}/bin/mustache $jsonDataPath ${template} > file
            '';

            installPhase = ''
              cp file $out
              chmod +x $out
            '';
          };

        mustacheTemplateContent = n: t: d: builtins.readFile "${mustacheTemplate n t d}";

        # provide a bun-baseline package that uses the baseline release to support older CPU architectures
        bun-baseline = prev.bun.overrideAttrs (old: (
          let
            sources = {
              "x86_64-linux" = prev.fetchurl {
                url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
                hash = "sha256-ytd1am7hbzQyoyj4Aj/FzUMRBoIurPptbTr7rW/cJNs=";
              };
            };
          in
          {
            pname = "bun-baseline";
            src = if (builtins.hasAttr system sources) then sources.${system} else old.src;
          }
        )
        );
      }
    );

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # Example usage
  modifications = _final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    customMaintainer = prev.lib.maintainers.overrideAttrs (oldAttrs: oldAttrs // {
      tcarrio = {
        email = "tom@carrio.dev";
        github = "tcarrio";
        githubId = 8659099;
        name = "Tom Carrio";
      };
    });
  };


  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
  trunk-packages = final: _prev: {
    trunk = import inputs.nixpkgs-trunk {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
