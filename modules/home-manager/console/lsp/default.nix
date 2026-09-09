{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.lsp;

  # Full language-server set from the historical console mixin. All from
  # nixpkgs-unstable (requires the unstable overlay) except where noted.
  serverSet = with pkgs.unstable; [
    nixd # Nix
    nil # Nix
    vscode-json-languageserver # JSON
    svelte-language-server # Svelte
    mdx-language-server # MDX
    astro-language-server # Astro
    kotlin-language-server # Kotlin
    bash-language-server # Bash
    prisma-language-server # Prisma
    nginx-language-server # Nginx
    yaml-language-server # YAML
    tailwindcss-language-server # Tailwind
    vue-language-server # Vue
    caddyfile-language-server # Caddyfile
    lua-language-server # Lua
    postgres-language-server # Postgres
    elmPackages.elm-language-server # Elm
    typescript-language-server # TypeScript
    rust-analyzer # Rust
    crates-lsp # Rust crates.toml
    just-lsp # Justfiles
    helm-ls # Helm
    systemd-language-server # Systemd
    tofu-ls # OpenTofu
    starpls # Starlark
    marksman # Markdown
    gopls # Golang
    regols # OPA Rego
    regal # OPA Rego
    vim-language-server # Vimlang
    phpactor # PHP
    glas # Gleam
    protobuf-language-server # Protobufs
    sqls # SQL
    dockerfile-language-server # Dockerfile
    package-version-server # package.json
    mpls # Markdown preview
  ];
in
{
  options.oxc.console.lsp = {
    enable = lib.mkEnableOption "the oxc language-server toolset (global installs)";

    servers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = serverSet;
      defaultText = lib.literalExpression "oxc server set (37 servers, unstable)";
      description = "Language server packages to install globally";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.servers;
  };
}
