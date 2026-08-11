# marker-pdf: Convert PDF (and, with the [full] extra, DOCX/PPTX/XLSX/EPUB/HTML
# and images) to markdown / JSON / HTML / chunks.
#
# Architecture (marker 2.x): the surya VLM that powers layout, OCR and table
# recognition is served by a *local inference server*. On macOS (MPS) and
# CPU-only Linux, surya auto-selects the `llamacpp` backend and spawns the
# upstream `llama-server` binary, locating it via `shutil.which()` or the
# `LLAMA_CPP_BINARY` env var (surya/inference/backends/llamacpp.py). The surya
# GGUF model auto-downloads from Hugging Face Hub (datalab-to/surya-ocr-2-gguf)
# on first run, or is pinned via SURYA_GGUF_LOCAL_*.
#
# So "backed by llama.cpp" just means: make `llama-server` discoverable.
# llama.cpp is a RUNTIME-only dependency -- the uv2nix venv build does not need
# it. Provide it through the `llamaCpp` argument:
#   - default (platform-aware): null on macOS (use `brew install llama.cpp`),
#                               nixpkgs `llama-cpp` on Linux (self-contained).
#   - override: marker-pdf.override { llamaCpp = pkgs.llama-cpp; }  # bundle everywhere
#               marker-pdf.override { llamaCpp = null; }            # always external
#
# The `dev` dependency-group (streamlit/fastapi/playwright/jupyter/...) is NOT
# part of uv2nix's `deps.default`, so only the production core deps are built.
# That yields the `marker` (batch) and `marker_single` (single file) CLIs. The
# `marker_gui`/`marker_server` entry points need the dev group and are not
# wrapped by default. Pass `withFull = true` for non-PDF format support.
#
# A small source patch relocates marker's BASE_DIR (FONT_DIR/OUTPUT_DIR/...) out
# of the read-only store into a writable per-user dir (overridable via
# MARKER_DATA_DIR, default ~/.local/share/marker), since marker downloads the
# GoNoto font there at runtime. See pkgs/marker-pdf/README.md.
#
# References:
# - https://github.com/datalab-to/marker
# - https://pyproject-nix.github.io/uv2nix/usage/getting-started.html

{
  lib,
  pkgs,
  uv2nixLib,
  llamaCpp ? if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.llama-cpp,
  withFull ? false,
}:

let
  inherit (uv2nixLib)
    uv2nix
    pyproject-nix
    pyproject-build-systems
    python
    ;

  # Pinned marker release (ships pyproject.toml + uv.lock at the repo root).
  version = "2.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "datalab-to";
    repo = "marker";
    rev = "v${version}";
    hash = "sha256-uapSTZI48PdIKHrbxxVib5WR1ZzF1haA9DJIomvrt8Y=";
  };

  # marker computes BASE_DIR as the parent of the installed `marker/` package
  # (i.e. .../site-packages) and derives FONT_DIR / OUTPUT_DIR /
  # DEBUG_DATA_FOLDER from it. The GoNoto font is *downloaded* into FONT_DIR at
  # runtime (marker/util.py does os.makedirs(FONT_DIR)), which PermissionErrors
  # under the read-only Nix store. BASE_DIR backs only writable outputs (nothing
  # is read from it), so relocate it to a per-user data dir, overridable via
  # MARKER_DATA_DIR. See pkgs/marker-pdf/README.md.
  patchedSrc = pkgs.runCommandLocal "marker-source-patched" { inherit src; } ''
    cp -r "$src" "$out"
    chmod -R u+w "$out"
    sed -i 's|^    BASE_DIR: str = .*|    BASE_DIR: str = os.environ.get("MARKER_DATA_DIR") or os.path.join(os.path.expanduser("~"), ".local", "share", "marker")|' \
      "$out/marker/settings.py"
  '';

  # Load the uv workspace from the lock file.
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = patchedSrc; };

  # Prefer pre-built wheels for the heavy ML deps (torch, surya, transformers...).
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
          # Add wheel/sdist fixups for native deps here if the build needs them.
        ]
      );

  # `deps.default` = production core deps only (no `dev` group). Optionally pull
  # the `full` extra for non-PDF format support (DOCX/PPTX/XLSX/EPUB/HTML).
  venv = pythonSet.mkVirtualEnv "marker-pdf-env" (
    if withFull then
      lib.mapAttrs (_name: _: [ "full" ]) workspace.deps.default
    else
      workspace.deps.default
  );

  # Runtime PATH: only llama-server discovery (when a llama.cpp is bundled).
  runtimeBinPath = lib.makeBinPath (lib.optional (llamaCpp != null) llamaCpp);

in
pkgs.stdenv.mkDerivation {
  pname = "marker-pdf";
  inherit version;

  # The venv already contains the marker package and its console scripts; this
  # derivation only re-wraps the runnable CLIs so we can control PATH and point
  # surya's llamacpp backend at the bundled `llama-server`.
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    # Wrap only the CLIs that work with the core deps. (marker_gui/marker_server
    # require the `dev` dependency-group and are intentionally not exposed.)
    for script in marker marker_single; do
      if [[ -x "${venv}/bin/$script" ]]; then
        makeWrapper "${venv}/bin/$script" "$out/bin/$script" \
          ${lib.optionalString (runtimeBinPath != "") "--prefix PATH : \"${runtimeBinPath}\""} \
          ${lib.optionalString (
            llamaCpp != null
          ) "--set-default LLAMA_CPP_BINARY \"${llamaCpp}/bin/llama-server\""}
      fi
    done

    runHook postInstall
  '';

  passthru = {
    inherit venv;
  };

  meta = with lib; {
    description = "Convert PDF (and other docs) to markdown/JSON/HTML with surya + llama.cpp";
    homepage = "https://github.com/datalab-to/marker";
    license = licenses.asl20;
    maintainers = with maintainers; [ tcarrio ];
    mainProgram = "marker_single";
    platforms = platforms.unix;
  };
}
