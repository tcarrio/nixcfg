# endcord: Feature rich Discord TUI client
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
    python
    ;

  # Fetch the source with the uv.lock file
  src = pkgs.fetchFromGitHub {
    owner = "sparklost";
    repo = "endcord";
    rev = "1.4.2";
    hash = "sha256-YY9NRK5ZXH5Ry7FCGQ158AySRcPwr+jNh2QrcP1YlV4=";
  };

  # Load the uv workspace from the source
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };

  # Create the pyproject overlay from the lock file
  # Using wheel preference for reliability (pre-built binaries)
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  # Get the base Python package set for the specified Python version
  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      python = lib.head (pyproject-nix.lib.util.filterPythonInterpreters {
        inherit (workspace) requires-python;
        inherit (pkgs) pythonInterpreters;
      });
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
        ]
      );

  # Build the virtual environment with all dependencies
  venv = pythonSet.mkVirtualEnv "endcord-env" workspace.deps.default;

in
venv.overrideAttrs (oldAttrs: {
  meta = (oldAttrs.meta or { }) // {
    description = " Feature rich Discord TUI client";
    homepage = "https://github.com/sparklost/endcord";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tcarrio ];
    mainProgram = "endcord";
    platforms = lib.platforms.unix;
  };
})
