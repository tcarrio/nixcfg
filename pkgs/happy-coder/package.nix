{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
  ripgrep,
  difftastic,
}:

buildNpmPackage (finalAttrs: {
  pname = "happy-coder";
  version = "1.2.0";

  # The CLI ("happy") is published to the npm registry. Its source previously
  # lived in a standalone `slopus/happy-cli` repository (now archived); it has
  # moved into the `slopus/happy` monorepo, whose `happy-cli` workspace package
  # is published as `happy`. pkgroll ships the prebuilt `dist/` but externalizes
  # the npm dependencies, so they still need installing -- the tarball itself is
  # not runnable on its own.
  src = fetchurl {
    url = "https://registry.npmjs.org/happy/-/happy-${finalAttrs.version}.tgz";
    hash = "sha256-GDxgYKUx0jTaXzLB/wALUBbHs8CKT3BWSQzRMlouZ/c=";
  };

  # Upstream is a pnpm monorepo and ships no npm lockfile, so vendor one
  # generated from the published package.json (whose `workspace:*` references
  # were resolved at publish time, e.g. @slopus/happy-wire -> 0.1.0).
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-2EXD6vOQ94BTYMvdprWWbpgJcrUhqePDodS0ukwHkvw=";

  # `dist/` is already built in the tarball; only install the dependencies. Skip
  # lifecycle scripts -- the postinstall would unpack the bundled prebuilt
  # binaries that we replace with the nixpkgs builds below.
  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];

  buildInputs = [
    ripgrep
    difftastic
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/happy
    cp -r node_modules $out/lib/happy/
    cp -r package.json dist bin scripts tools $out/lib/happy/

    # Drop the bundled prebuilt ripgrep/difftastic archives (~140 MB) and point
    # the CLI at the nixpkgs builds instead: happy resolves these tools at
    # tools/unpacked/{rg,difft} and falls back to PATH, so both are covered.
    rm -rf $out/lib/happy/tools/archives
    mkdir -p $out/lib/happy/tools/unpacked
    ln -s ${ripgrep}/bin/rg $out/lib/happy/tools/unpacked/rg
    ln -s ${difftastic}/bin/difft $out/lib/happy/tools/unpacked/difft

    # `happy.mjs` re-execs node with --no-warnings/--no-deprecation unless they
    # are already set; pass them here so the CLI boots in-process, and keep node
    # and the search tools on PATH for the daemon and any fallback lookups.
    mkdir -p $out/bin
    for bin in happy happy-mcp; do
      makeWrapper ${nodejs}/bin/node $out/bin/$bin \
        --add-flags "--no-warnings --no-deprecation $out/lib/happy/bin/$bin.mjs" \
        --prefix PATH : ${
          lib.makeBinPath [
            nodejs
            ripgrep
            difftastic
          ]
        }
    done

    runHook postInstall
  '';

  meta = {
    description = "Mobile and web client for Claude Code and Codex with end-to-end encryption";
    homepage = "https://github.com/slopus/happy";
    changelog = "https://github.com/slopus/happy/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onsails ];
    mainProgram = "happy";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
