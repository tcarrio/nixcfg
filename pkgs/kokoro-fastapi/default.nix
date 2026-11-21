# kokoro-fastapi: Kokoro-82M TTS served through an OpenAI-compatible FastAPI,
# natively on macOS with Metal (MPS) inference. Mirrors upstream's
# start-gpu_mac.sh: DEVICE_TYPE=mps, PYTORCH_ENABLE_MPS_FALLBACK=1.
#
# Layout: unlike marker-pdf (installed venv package), this app runs from the
# source tree — upstream launches `uvicorn api.src.main:app` with the project
# root on PYTHONPATH (api/ and api/src/ are namespace dirs with __init__.py).
# core/paths.py joins relative MODEL_DIR/VOICES_DIR onto api/src, and resolves
# the web player as <project root>/web, so the store keeps upstream's tree:
#   $out/share/kokoro-fastapi/{api/src, web, VERSION}
#   $out/share/kokoro-fastapi/api/src/models/v1_0/{kokoro-v1_0.pth, config.json}
#
# Model weights are a fetchurl FOD pinned to the same upstream sha256 digests
# as docker/scripts/download_model.py (hex digests from the pinned HF commit).
# Voices (.pt packs) ship in the repo. HF_HUB_OFFLINE=1 keeps startup
# network-free (upstream's check_hub telemetry + any hub lookups are skipped).
#
# References:
# - https://github.com/remsky/Kokoro-FastAPI
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

  version = "0.10.1-rc1";
  src = pkgs.fetchFromGitHub {
    owner = "remsky";
    repo = "Kokoro-FastAPI";
    rev = "ffa06918946413667af51e8c3459e598dc78fdf0";
    hash = "sha256-SP+6j4xSl9ghzOOsaycpBfEkp0Ht2SH5HlWgSxY34Ko=";
  };

  # Kokoro v1.0 weights, digest-pinned to the HuggingFace commit referenced by
  # upstream's download_model.py (EXPECTED_SHA256 there). Kept as REAL files in
  # one directory: the app realpaths the model and looks for config.json in its
  # dirname, so a per-file symlink into a bare FOD breaks config resolution.
  modelDir = pkgs.runCommandLocal "kokoro-v1_0-model" { } ''
    mkdir -p "$out"
    cp ${
      pkgs.fetchurl {
        url = "https://huggingface.co/hexgrad/Kokoro-82M/resolve/41e5892b9d8b43e56fc560f892312a328a410973/kokoro-v1_0.pth";
        sha256 = "496dba118d1a58f5f3db2efc88dbdc216e0483fc89fe6e47ee1f2c53f18ad1e4";
      }
    } "$out/kokoro-v1_0.pth"
    cp ${
      pkgs.fetchurl {
        url = "https://huggingface.co/hexgrad/Kokoro-82M/resolve/41e5892b9d8b43e56fc560f892312a328a410973/config.json";
        sha256 = "5abb01e2403b072bf03d04fde160443e209d7a0dad49a423be15196b9b43c17f";
      }
    } "$out/config.json"
  '';

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };

  # Prefer pre-built wheels for the heavy ML deps (torch, transformers, spacy,
  # av, tiktoken, ...). torch resolves from PyPI (MPS-enabled darwin build);
  # the pytorch-cu* indexes only apply to the GPU extras we don't install.
  #
  # Select the `cpu` conflict branch: it carries torch 2.8.0 and its support
  # deps (sympy, networkx, jinja2, ...) for non-CUDA platforms. Without an
  # extra, uv.lock's synthetic-extras markers drop torch's dep edges — the
  # venv builds but `import transformers` dies on missing sympy at runtime.
  # deps must match the venv spec: mkPyprojectOverlay defaults to deps.all,
  # which selects every branch (cpu/gpu/rocm) at once — ambiguous, an error.
  deps = {
    kokoro-fastapi = [ "cpu" ];
  };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
    dependencies = deps;
  };

  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
          # Build-system fixups: uv doesn't lock build systems, so sdist-only
          # packages need their build deps supplied here. Sdist-only set from
          # uv.lock: docopt, jieba, unidic (legacy setuptools setup.py) and
          # pyopenjtalk (cmake + cython C extension).
          (final: prev: {
            docopt = prev.docopt.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
            });
            jieba = prev.jieba.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
            });
            unidic = prev.unidic.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
            });
            pyopenjtalk = prev.pyopenjtalk.overrideAttrs (old: {
              nativeBuildInputs =
                old.nativeBuildInputs
                ++ final.resolveBuildSystem {
                  setuptools = [ ];
                  setuptools-scm = [ ];
                  cython = [ ];
                  cmake = [ ];
                  numpy = [ ];
                };
            });
          })
        ]
      );

  venv = pythonSet.mkVirtualEnv "kokoro-fastapi-env" deps;

  appDir = "$out/share/kokoro-fastapi";

  base = pkgs.stdenv.mkDerivation {
    pname = "kokoro-fastapi";
    inherit version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "${appDir}"

      cp -r ${src}/api "${appDir}/api"
      cp -r ${src}/web "${appDir}/web"
      cp ${src}/VERSION "${appDir}/VERSION"
      chmod -R u+w "${appDir}"

      mkdir -p "${appDir}/api/src/models/v1_0"

      # MODEL_DIR=src/models resolves here; the app joins v1_0/kokoro-v1_0.pth
      # itself. Replace the repo's placeholder dir with the symlinked model dir.
      rm -rf "${appDir}/api/src/models/v1_0"
      ln -s "${modelDir}" "${appDir}/api/src/models/v1_0"

      # Writable dirs (temp audio for the web player) live outside the store.
      makeWrapper "${venv}/bin/uvicorn" "$out/bin/kokoro-fastapi" \
        --chdir "${appDir}" \
        --set-default PYTHONPATH "${appDir}" \
        --set-default USE_GPU "true" \
        --set-default DEVICE_TYPE "mps" \
        --set-default PYTORCH_ENABLE_MPS_FALLBACK "1" \
        --set-default MODEL_DIR "src/models" \
        --set-default VOICES_DIR "src/voices/v1_0" \
        --set-default WEB_PLAYER_PATH "web" \
        --set-default HF_HUB_OFFLINE "1" \
        --run 'export TEMP_FILE_DIR="''${TEMP_FILE_DIR:-$HOME/.local/state/kokoro-fastapi/temp}"; mkdir -p "$TEMP_FILE_DIR"'

      runHook postInstall
    '';

    nativeBuildInputs = [ pkgs.makeWrapper ];

    passthru = {
      inherit venv;
    };

    meta = with lib; {
      description = "Kokoro-82M TTS with OpenAI-compatible API, native macOS MPS inference";
      homepage = "https://github.com/remsky/Kokoro-FastAPI";
      license = licenses.asl20;
      maintainers = with maintainers; [ tcarrio ];
      mainProgram = "kokoro-fastapi";
      platforms = platforms.darwin;
    };
  };

  # German variant, exposed as a subpackage: nix build .#kokoro-fastapi.de
  # (installable attrpaths drill derivation attrs directly, so `de` must sit
  # at the top level — a plain passthru member is not reachable that way)
  de = pkgs.callPackage ./de.nix {
    inherit base uv2nixLib;
  };
in
base
// {
  inherit de;
  passthru = base.passthru // {
    inherit de;
  };
}
