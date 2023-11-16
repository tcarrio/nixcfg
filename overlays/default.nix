# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev:
    (import ../pkgs { pkgs = final; })
    // rec {
      templateFile = name: template: data:
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

        templateFileContent = n: t: d: builtins.readFile "${templateFile n t d}";
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  trunk-packages = final: _prev: {
    trunk = import inputs.nixpkgs-trunk {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
