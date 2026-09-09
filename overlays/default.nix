# This file defines overlays.
#
# Overlays are parameterized for external consumption: the input-derived
# builders (nixvim, uv2nix stack, bun2nix) are nullable. `nixcfg.overlays.*`
# applies this file with nixcfg's own locked inputs; external consumers who
# want different revisions can build the same overlays via
# `nixcfg.lib.mkOverlays { ... }` with their own inputs.
{ inputs ? { }, nixvim ? null, bun2nix ? null, python ? null, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    let
      inherit (final.stdenv.hostPlatform) system;

      inherit (import ../lib/bun.nix { }) mkBunDerivation;

      # Nullable: when bun2nix input is absent (external consumer), gqurl
      # and other bun-built packages are simply omitted.
      mkStandardBun =
        if bun2nix != null then mkBunDerivation bun2nix.packages.${system}.default else null;

      # Nullable uv2nix stack; python resolved against the overlaid set so it
      # follows the consumer's nixpkgs, not a hardcoded interpreter pin.
      uv2nixLib =
        if inputs ? uv2nix then
          {
            inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
            python = if python != null then python else final.python3;
          }
        else
          null;

      customPkgs = import ../pkgs {
        pkgs = final;
        inherit nixvim;
        mkStandardBun = mkStandardBun;
        uv2nixLib = uv2nixLib;
      };
    in
    customPkgs
    // rec {
      # Override nixvim to automatically use the current nixpkgs allowUnfree configuration
      mustacheTemplate =
        name: template: data:
        prev.stdenv.mkDerivation {
          name = "${name}";

          nativeBuildInpts = [ prev.mustache-go ];

          # Pass Json as file to avoid escaping
          passAsFile = [ "jsonData" ];
          jsonData = builtins.toJSON data;

          # Disable phases which are not needed. In particular the unpackPhase will
          # fail, if no src attribute is set
          phases = [
            "buildPhase"
            "installPhase"
          ];

          buildPhase = ''
            ${prev.mustache-go}/bin/mustache $jsonDataPath ${template} > file
          '';

          installPhase = ''
            cp file $out
            chmod +x $out
          '';
        };

      mustacheTemplateContent =
        n: t: d:
        builtins.readFile "${mustacheTemplate n t d}";

      # provide a bun-baseline package that uses the baseline release to support older CPU architectures
      bun-baseline = prev.bun.overrideAttrs (
        old:
        (
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
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # Example usage
  #
  # NOTE: do not override `lib` here — pkgs depends on lib, so an overlay
  # redefining it recurses. The previous customMaintainer entry was broken
  # (overrideAttrs on an attrset) and unreferenced; add maintainers directly
  # in package derivations instead.
  modifications = _final: _prev: { };


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
