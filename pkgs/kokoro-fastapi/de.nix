# kokoro-fastapi.de: German (lang_code 'd') variant of the upstream package.
#
# Upstream Kokoro-82M has no German: no 'd' lang code (kokoro 0.9.4
# LANG_CODES), no German G2P (misaki[de] unmerged upstream), no German
# voicepacks, and the base checkpoint was never trained on German. German here
# is assembled from semidark's forks + the Thorsten-Voice German fine-tune:
#
#   - semidark/kokoro (PR #317): registers lang_code 'd' -> misaki.de DEG2P
#   - semidark/misaki @6d252a2 (rev pinned by Thorsten-Voice): misaki/de.py,
#     espeak-ng based German text normalization + phonemization
#   - Thorsten-Voice/Kokoro (HF, Apache-2.0, CC0 data): German fine-tuned
#     checkpoint (epoch 5) + thorsten.pt voicepack
#
# Both forks are pure Python and ABI-compatible supersets of their PyPI 0.9.4
# counterparts, so they SHADOW the venv copies via PYTHONPATH prepended by
# this wrapper (import kokoro/misaki resolves to the fork first). Their
# runtime deps (torch, transformers, espeakng-loader, ...) come from the base
# venv — the fork derivations build no dependency closure.
#
# The voicepack is renamed thorsten.pt -> dm_thorsten.pt: the app derives the
# pipeline language from the voice prefix (kokoro_v1.py: voice_name[0] ==
# 'd'), so the d-prefix name is what routes synthesis through the German G2P.
#
# One source patch (patches/kokoro-de-upsilon.patch) applies the ʏ->y
# vocabulary substitution the German training data was prepared with; see the
# patch comment.

{
  lib,
  pkgs,
  base,
  uv2nixLib,
}:

let
  inherit (uv2nixLib) python;

  kokoroDe = python.pkgs.buildPythonPackage rec {
    pname = "kokoro-de";
    version = "0.9.4-de";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "semidark";
      repo = "kokoro";
      rev = "b96fef95e6a746495f92443fac7c688f90fc57fc";
      hash = "sha256-V5wKQ0UPmIhzoZteZsygeMQMpruSKrDDyHYCJVsM2NY=";
    };

    patches = [ ./patches/kokoro-de-upsilon.patch ];

    nativeBuildInputs = [ python.pkgs.hatchling ];

    # Runtime deps come from the base package's venv (shadow layer).
    doCheck = false;
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ ];

    meta = with lib; {
      description = "Kokoro TTS fork with German (de) language support";
      homepage = "https://github.com/semidark/kokoro";
      license = licenses.asl20;
    };
  };

  misakiDe = python.pkgs.buildPythonPackage rec {
    pname = "misaki-de";
    version = "0.9.4-de";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "semidark";
      repo = "misaki";
      rev = "6d252a2e02f3b030f22f56686f1a73786c16ffc8";
      hash = "sha256-FahGW8cl0Ho6sK2+fkDW/PxZYEPgSCusK2fAKq9HD/o=";
    };

    nativeBuildInputs = [ python.pkgs.hatchling ];

    doCheck = false;
    dontCheckRuntimeDeps = true;
    pythonImportsCheck = [ ];

    meta = with lib; {
      description = "Misaki G2P fork with German (misaki.de) support";
      homepage = "https://github.com/semidark/misaki";
      license = licenses.mit;
    };
  };

  # Shadow layer prepended to PYTHONPATH: fork site-packages win over venv's.
  forkLayer = lib.makeSearchPath python.sitePackages [
    kokoroDe
    misakiDe
  ];

  # German model tree mirrors the layout the app expects:
  #   MODEL_DIR/v1_0/kokoro-v1_0.pth + config.json (model_config.py joins the
  #   v1_0/kokoro-v1_0.pth filename onto MODEL_DIR), VOICES_DIR/*.pt packs.
  deModel = pkgs.runCommandLocal "kokoro-de-model" { } ''
    mkdir -p "$out/models/v1_0" "$out/voices"
    cp ${
      pkgs.fetchurl {
        url = "https://huggingface.co/Thorsten-Voice/Kokoro/resolve/main/model.pth";
        hash = "sha256-Nt3hXEqADP0atUDMtEdturYE/gP/fJN9l26787SeWc4=";
      }
    } "$out/models/v1_0/kokoro-v1_0.pth"
    cp ${
      pkgs.fetchurl {
        url = "https://huggingface.co/Thorsten-Voice/Kokoro/resolve/main/config.json";
        hash = "sha256-WrsB4kA7ByvwPQT94WBEPiCdeg2tSaQjvhUZa5tDwX8=";
      }
    } "$out/models/v1_0/config.json"
    cp ${
      pkgs.fetchurl {
        url = "https://huggingface.co/Thorsten-Voice/Kokoro/resolve/main/voices/thorsten.pt";
        hash = "sha256-nZi3devOHPw2no+aPujuJgzWEt/7R3y6hXSREjYjBtc=";
      }
    } "$out/voices/dm_thorsten.pt"
  '';

in
pkgs.stdenv.mkDerivation {
  pname = "kokoro-fastapi-de";
  inherit (base) version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # Outer wrapper around the base wrapper: outer --set values are exported
  # before the inner script runs, so the inner --set-default defaults defer
  # to them (MODEL_DIR/VOICES_DIR point at the German tree, warmup voice is
  # dm_thorsten). MODEL_DIR/VOICES_DIR are absolute paths — core/paths.py
  # os.path.join(_API_DIR, <absolute>) keeps them verbatim.
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    makeWrapper "${base}/bin/kokoro-fastapi" "$out/bin/kokoro-fastapi-de" \
      --prefix PYTHONPATH : "${forkLayer}" \
      --set MODEL_DIR "${deModel}/models" \
      --set VOICES_DIR "${deModel}/voices" \
      --set DEFAULT_VOICE "dm_thorsten"

    runHook postInstall
  '';

  passthru = {
    inherit deModel;
  };

  meta = with lib; {
    description = "kokoro-fastapi with German TTS (Thorsten-Voice fine-tune, lang_code 'd')";
    homepage = "https://huggingface.co/Thorsten-Voice/Kokoro";
    license = licenses.asl20;
    maintainers = with maintainers; [ tcarrio ];
    mainProgram = "kokoro-fastapi-de";
    platforms = platforms.darwin;
  };
}
