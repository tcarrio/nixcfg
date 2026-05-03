{ mkStandardBun, ... }:
let
  base = mkStandardBun { path = ./.; };
in
base.overrideAttrs (old: {
  pname = "gqurl";
  meta.mainProgram = "gqurl";
  buildPhase = ''
    runHook preBuild
    bun build index.ts --outdir . --target bun
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp index.js $out/bin/gqurl.js
    cat > $out/bin/gqurl <<'SCRIPT'
#!/bin/sh
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
exec bun "$SCRIPT_DIR/gqurl.js" "$@"
SCRIPT
    chmod +x $out/bin/gqurl
    runHook postInstall
  '';
})
