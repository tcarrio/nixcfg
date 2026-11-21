# sprigo: local-first AI language learning (Tauri 2: React/TS frontend, Rust
# shell). Darwin-only for now; Linux later (whisper-rs is already gated
# non-macos upstream, so the Rust side would need that dep re-enabled).
#
# Three stages, mirroring upstream's `tauri build`:
#   1. frontend: buildPnpmPackage runs `tsc && vite build` -> dist/
#   2. rust: buildRustPackage on src-tauri; tauri-codegen embeds dist/ into
#      the binary at compile time (frontendDist = "../dist"), so the dist
#      output is symlinked next to src-tauri before cargo build
#   3. app: hand-assembled Sprigo.app — upstream's bundler (icons/plist/
#      resources) is replaced by a static Info.plist (verified against the
#      official release bundle) + ad-hoc codesign with upstream's
#      entitlements (mic + camera; hardened-runtime TCC needs them)
#
# The bundled Whisper model (macOS speech recognition uses Apple's framework,
# whisper-rs is compiled out on darwin) is included for bundle parity with
# upstream releases. The updater plugin is compiled in but its GitHub-release
# endpoint won't serve nix-built artifacts; updates come from this flake.
#
# Carries one local patch: patches/wkwebview-audio-gesture.patch — WKWebView
# only unlocks AudioContext.resume() synchronously inside a user gesture;
# after Tauri IPC awaits it rejects, so lesson auto-speak and the Listen
# button fell back to the system voice without ever reaching a local TTS
# server (found while wiring Sprigo to kokoro-fastapi.de).

{
  lib,
  pkgs,
}:

let
  version = "1.12.0";

  src = pkgs.fetchFromGitHub {
    owner = "ozerozdas";
    repo = "sprigo";
    rev = "586c9742848abdd848c38531d6c48194d26a5c32";
    hash = "sha256-il2n0ZIc7yc+ZxYGvflQK4wncjawfDq9icabrEolet4=";
  };

  ttsPatch = ./patches/wkwebview-audio-gesture.patch;

  # 1. Frontend: vite dist. buildPnpmPackage is gone from nixpkgs 26.05, so
  # this is the hook-based equivalent: pnpmConfigHook installs the offline
  # store, pnpmBuildHook runs `pnpm run build` (tsc && vite build).
  # pnpm from unstable: 26.05's pnpm_10 (10.34.0) is insecure-flagged.
  pnpm = pkgs.unstable.pnpm_10;
  frontend = pkgs.stdenv.mkDerivation {
    pname = "sprigo-frontend";
    inherit version src;

    patches = [ ttsPatch ];

    pnpmDeps = pnpm.fetchDeps {
      pname = "sprigo-frontend";
      inherit src version;
      fetcherVersion = 4;
      hash = "sha256-gPMoE3Sr6/MLzUd9qUaeVKCZLM7c1TxQTKr2upF0v68=";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pnpm.configHook
      pkgs.pnpmBuildHook
    ];

    installPhase = ''
      runHook preInstall
      cp -r dist "$out"
      runHook postInstall
    '';
  };

  # 2. Rust shell with the frontend embedded.
  sprigo-bin = pkgs.rustPlatform.buildRustPackage {
    pname = "sprigo-bin";
    inherit version src;

    sourceRoot = "${src.name}/src-tauri";

    # tts.ts patch applies to the frontend only (compiled into dist); the
    # Rust shell just embeds the already-patched frontend below.

    # tauri-codegen reads the frontend from ../dist (frontendDist in
    # tauri.conf.json) at compile time.
    postPatch = ''
      chmod u+w ..
      ln -s "${frontend}" ../dist
    '';

    cargoLock.lockFile = "${src}/src-tauri/Cargo.lock";

    # tauri 2.12 dropped `custom-protocol` from tauri's default features; the
    # tauri CLI normally enables it. Without it tauri-macros builds the
    # context in dev mode, embeds nothing, and the app white-screens trying
    # to reach the devUrl (localhost:1420).
    cargoBuildFlags = [ "--features=tauri/custom-protocol" ];

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.cmake # whisper-rs-sys builds bundled whisper.cpp via cmake
    ];

    # Frameworks (WebKit et al) resolve through the darwin stdenv SDK; the
    # legacy darwin.apple_sdk.frameworks set is removed in nixpkgs 26.05.
    buildInputs = [ pkgs.apple-sdk ];

    # tests need a display + the tauri shell
    doCheck = false;

    meta = with lib; {
      description = "Local-first AI language learning (Tauri shell binary)";
      homepage = "https://github.com/ozerozdas/sprigo";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
  };

  # Bundled Whisper model (~57 MB), for parity with upstream release bundles.
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base-q5_1.bin";
    hash = "sha256-Qi8a5FKt5vMKAE1+XGpDGV5EM7w3C/I/rJzFkfAaiJg=";
  };

in
pkgs.stdenv.mkDerivation {
  pname = "sprigo";
  inherit version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # NOTE: unsigned. The nix daemon's allowed-impure-host-deps excludes
  # /usr/bin/codesign, and nixpkgs has no ad-hoc codesigner (rcodesign needs
  # an identity). Unsigned bundles still get TCC mic/camera prompts per
  # bundle id; re-sign locally if keychain/entitlement enforcement matters:
  #   codesign --force --sign - --entitlements Entitlements.plist Sprigo.app

  installPhase = ''
    runHook preInstall

    app="$out/Applications/Sprigo.app"
    mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/resources" "$out/bin"

    cp "${sprigo-bin}/bin/sprigo" "$app/Contents/MacOS/sprigo"
    cp "${src}/src-tauri/icons/icon.icns" "$app/Contents/Resources/icon.icns"
    cp "${whisperModel}" "$app/Contents/Resources/resources/ggml-base-q5_1.bin"
    cp "${./Info.plist}" "$app/Contents/Info.plist"

    # Run the bundle's binary (not a copy): Tauri resolves its resource dir
    # relative to the executable, so a bare $out/bin copy would miss it.
    cat > "$out/bin/sprigo" <<EOF
    #!/bin/sh
    exec "$out/Applications/Sprigo.app/Contents/MacOS/sprigo" "\$@"
    EOF
    chmod +x "$out/bin/sprigo"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Local-first AI language learning, nix-built with the WKWebView audio-gesture fix";
    homepage = "https://github.com/ozerozdas/sprigo";
    license = licenses.mit;
    maintainers = with maintainers; [ tcarrio ];
    mainProgram = "sprigo";
    platforms = platforms.darwin;
  };
}
