{
  lib,
  stdenv,
  fetchurl,
  ...
}:

let
  version = "0.75.2";

  # Rolling "latest" download endpoint with no version pinning in the URL.
  # Bump version and all four hashes together with ./update.sh
  hashes = {
    x86_64-linux = "sha256-JXyUERI5CKQy5zMMXwNU37HLyzU3weFLhhDGtz2mOzQ=";
    aarch64-linux = "sha256-sW5dmEjT2T7MA9A7SV6BStJeIU1lb6F+A+YVEMskTqo=";
    x86_64-darwin = "sha256-jp8BDIuoZLI9MW4dH/B4Oi+Coeeqmg0+VsgEjPDl600=";
    aarch64-darwin = "sha256-Ie3Kmz7tg/km9qNAlvTaIeG33kDCcg9qlzfgXEpBuMg=";
  };

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "bluebox: unsupported kernel ${stdenv.hostPlatform.parsed.kernel.name}";

  arch =
    if stdenv.hostPlatform.isx86_64 then
      "amd64"
    else if stdenv.hostPlatform.isAarch64 then
      "arm64"
    else
      throw "bluebox: unsupported CPU ${stdenv.hostPlatform.parsed.cpu.name}";
in
stdenv.mkDerivation {
  pname = "bluebox";
  inherit version;

  src = fetchurl {
    # Named to keep the query string out of the store path name
    name = "bluebox-${version}-${os}-${arch}";
    url = "https://app.bluebox.ai/download/bluebox?os=${os}&arch=${arch}";
    hash =
      hashes.${stdenv.hostPlatform.system}
        or (throw "bluebox: unsupported system ${stdenv.hostPlatform.system}");
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # Preserve the upstream binary as-is; stripping would break the macOS signature
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 $src $out/bin/bluebox
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Bluebox CLI";
    homepage = "https://app.bluebox.ai";
    license = lib.licenses.unfree;
    mainProgram = "bluebox";
    platforms = builtins.attrNames hashes;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ tcarrio ];
  };
}
