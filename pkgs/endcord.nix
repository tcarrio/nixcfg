# endcord: Feature rich Discord TUI client
#
# This package runs endcord from source with a uv2nix-managed virtual environment.
# The upstream build.py requires network access (uv sync), so instead we:
#   1. Patch pyproject.toml to declare Cython as a build dependency
#   2. Let uv2nix build the venv including compiled Cython extensions
#   3. Copy the application source and create a wrapper for main.py
#
# Note: The media dependency group (av, pillow, dave-py) is not yet included,
# so terminal ASCII media rendering is unavailable. Media can still be opened
# in external applications.
#
# Optional runtime dependencies (install separately):
#   xclip | wl-clipboard  - Clipboard support (X11 / Wayland)
#   aspell + aspellDicts  - Spellchecking
#   yt-dlp / mpv          - YouTube playback
#   libsecret + gnome-keyring - Secure token storage
#
# References:
# - https://github.com/sparklost/endcord
# - https://pyproject-nix.github.io/uv2nix/usage/getting-started.html

{
  lib,
  pkgs,
  uv2nixLib,
}:

let
  inherit (uv2nixLib)
    uv2nix
    pyproject-nix
    pyproject-build-systems
    ;

  python = pkgs.python313;

  src = pkgs.fetchFromGitHub {
    owner = "sparklost";
    repo = "endcord";
    rev = "1.4.2";
    hash = "sha256-YY9NRK5ZXH5Ry7FCGQ158AySRcPwr+jNh2QrcP1YlV4=";
  };

  patchedSrc = pkgs.runCommandLocal "endcord-source-patched" { inherit src; } ''
    cp -r $src $out
    chmod -R u+w $out
    cat >> $out/pyproject.toml << 'EOF'

    [build-system]
    requires = ["setuptools", "cython"]
    build-backend = "setuptools.build_meta"
    EOF
  '';

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = patchedSrc; };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
        ]
      );

  venv = pythonSet.mkVirtualEnv "endcord-env" workspace.deps.default;

in
pkgs.stdenv.mkDerivation {
  pname = "endcord";
  version = "1.4.2";

  inherit src;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  buildInputs = [ python ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/endcord
    cp -r endcord main.py themes $out/share/endcord/

    mkdir -p $out/bin
    makeWrapper ${python.interpreter} $out/bin/endcord \
      --prefix PYTHONPATH : "$out/share/endcord:${venv}/${python.sitePackages}" \
      --add-flags "$out/share/endcord/main.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Feature rich Discord TUI client";
    homepage = "https://github.com/sparklost/endcord";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tcarrio ];
    mainProgram = "endcord";
    platforms = platforms.unix;
  };
}
