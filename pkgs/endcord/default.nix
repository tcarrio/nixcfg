# endcord: Feature rich Discord TUI client
#
# This package runs endcord from source with a uv2nix-managed virtual environment.
# The upstream build.py requires network access (uv sync), so instead we:
#   1. Patch pyproject.toml to declare Cython as a build dependency
#   2. Let uv2nix build the venv including compiled Cython extensions
#   3. Copy the application source and create a wrapper for main.py
#
# Variants:
#   endcord             - lite, no terminal ASCII media rendering
#   endcord.override { withMedia = true; }  - full media support (av, pillow, dave-py)
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
  withMedia ? false,
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

  venv = pythonSet.mkVirtualEnv "endcord-env" (
    if withMedia then
      lib.mapAttrs (name: _: [ "media" ]) workspace.deps.default
    else
      workspace.deps.default
  );

  pname = if withMedia then "endcord" else "endcord-lite";

  isLinux = pkgs.stdenv.isLinux;
  ldLibraryPath = lib.optionalString (withMedia && isLinux) (lib.makeLibraryPath [ pkgs.libpulseaudio ]);
  binPath = lib.makeBinPath (lib.optional (withMedia && isLinux) pkgs.pulseaudio);

in
pkgs.stdenv.mkDerivation {
  inherit pname;
  version = "1.4.2";

  inherit src;

  patches = [ ./patches/terminal-utils-select.patch ];

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  buildInputs = [ python ]
    ++ lib.optional (withMedia && isLinux) pkgs.pulseaudio;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/endcord
    cp -r endcord main.py themes $out/share/endcord/

    mkdir -p $out/bin
    makeWrapper ${python.interpreter} $out/bin/endcord \
      ${lib.optionalString (ldLibraryPath != "") "--prefix LD_LIBRARY_PATH : \"${ldLibraryPath}\""} \
      --prefix PYTHONPATH : "$out/share/endcord:${venv}/${python.sitePackages}" \
      ${lib.optionalString (binPath != "") "--prefix PATH : \"${binPath}\""} \
      --add-flags "$out/share/endcord/main.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Feature rich Discord TUI client${lib.optionalString (!withMedia) " (lite, no media support)"}";
    homepage = "https://github.com/sparklost/endcord";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tcarrio ];
    mainProgram = "endcord";
    platforms = platforms.unix;
  };
}
