# Serena MCP Server package built with uv2nix
# Serena is a coding agent toolkit that turns an LLM into a fully-featured agent
# that works directly on your codebase with semantic code retrieval and editing.
#
# Usage: serena start-mcp-server --project-root /path/to/project
#
# References:
# - https://github.com/oraios/serena
# - https://pyproject-nix.github.io/uv2nix/usage/getting-started.html

{ lib
, pkgs
, uv2nixLib
}:

let
  inherit (uv2nixLib) uv2nix pyproject-nix pyproject-build-systems python;

  # Fetch the Serena source with the uv.lock file
  src = pkgs.fetchFromGitHub {
    owner = "oraios";
    repo = "serena";
    rev = "v0.1.4";
    hash = "sha256-oj5iaQZa9gKjjaqq/DDT0j5UqVbPjWEztSuaOH24chI=";
  };

  # Load the uv workspace from the source
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };

  # Create the pyproject overlay from the lock file
  # Using wheel preference for reliability (pre-built binaries)
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  # Get the base Python package set for the specified Python version
  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {
    inherit python;
  }).overrideScope
    (
      lib.composeManyExtensions [
        pyproject-build-systems.overlays.default
        overlay
      ]
    );

  # Build the virtual environment with all dependencies
  venv = pythonSet.mkVirtualEnv "serena-env" workspace.deps.default;

in
venv.overrideAttrs (oldAttrs: {
  meta = (oldAttrs.meta or { }) // {
    description = "A coding agent toolkit that turns an LLM into a fully-featured agent working directly on your codebase";
    homepage = "https://github.com/oraios/serena";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tcarrio ];
    mainProgram = "serena";
    platforms = lib.platforms.unix;
  };
})
