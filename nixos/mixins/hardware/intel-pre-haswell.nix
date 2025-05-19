# Configurations to support Intel hardware pre-Haswell architecture
_: {
  nixpkgs.overlays = [
    (_final: prev: {
      # provide a bun package that uses the baseline release to support older CPU architectures
      bun = prev.bun.overrideAttrs (old: (
        let
          sources = {
            "x86_64-linux" = prev.fetchurl {
              url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
              hash = "sha256-ytd1am7hbzQyoyj4Aj/FzUMRBoIurPptbTr7rW/cJNs=";
            };
          };
        in
        {
          src = sources.${prev.stdenvNoCC.hostPlatform.system} or old.src;
        }
      )
      );
    })
  ];
}
