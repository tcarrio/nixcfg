{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  ext = {
    # bun = {
    #   name = "oven.bun-vscode";
    #   publisher = "Oven";
    #   version = "0.0.12";
    #   sha256 = "sha256-9dp8/gLAb8OJnmsLVbOAKAYZ5whavDW2Ak+WhLqEbJk=";
    # };
    language-hugo-vscode = {
      name = "language-hugo-vscode";
      publisher = "budparr";
      version = "1.3.1";
      sha256 = "sha256-9dp8/gLAb8OJnmsLVbOAKAYZ5whavPW2Ak+WhLqEbJk=";
    };
    linux-desktop-file = {
      name = "linux-desktop-file";
      publisher = "nico-castell";
      version = "0.0.21";
      sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
    };
    non-breaking-space-highlighter = {
      name = "non-breaking-space-highlighter";
      publisher = "viktorzetterstrom";
      version = "0.0.3";
      sha256 = "sha256-t+iRBVN/Cw/eeakRzATCsV8noC2Wb6rnbZj7tcZJ/ew=";
    };
    pubspec-assist = {
      name = "pubspec-assist";
      publisher = "jeroen-meijer";
      version = "2.3.2";
      sha256 = "sha256-+Mkcbeq7b+vkuf2/LYT10mj46sULixLNKGpCEk1Eu/0=";
    };
    simple-rst = {
      name = "simple-rst";
      publisher = "trond-snekvik";
      version = "1.5.3";
      sha256 = "sha256-0gPqckwzDptpzzg1tP4I9WQfrXlflO+G0KcAK5pEie8=";
    };
    vala = {
      name = "vala";
      publisher = "prince781";
      version = "1.0.8";
      sha256 = "sha256-IuIb7vLNiE3rzVHOsjInaYLzNYORbwabQq0bfaPLlqc=";
    };
    vscode-front-matter = {
      name = "vscode-front-matter";
      publisher = "eliostruyf";
      version = "8.4.0";
      sha256 = "sha256-L0PbZ4HxJAlxkwVcZe+kBGS87yzg0pZl89PU0aUVYzY=";
    };
    vscode-mdx = {
      name = "vscode-mdx";
      publisher = "unifiedjs";
      version = "1.4.0";
      sha256 = "sha256-qqqq0QKTR0ZCLdPltsnQh5eTqGOh9fV1OSOZMjj4xXg=";
    };
    vscode-mdx-preview = {
      name = "vscode-mdx-preview";
      publisher = "xyc";
      version = "0.3.3";
      sha256 = "sha256-OKwEqkUEjHIJrbi9S2v2nJrZchYByDU6cXHAn7uhxcQ=";
    };
    vscode-power-mode = {
      name = "vscode-power-mode";
      publisher = "hoovercj";
      version = "3.0.2";
      sha256 = "sha256-ZE+Dlq0mwyzr4nWL9v+JG00Gllj2dYwL2r9jUPQ8umQ=";
    };
    remote-ssh-edit = {
      name = "remote-ssh-edit";
      publisher = "ms-vscode-remote";
      version = "0.47.2";
      sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
    };
    rust-analyzer = {
      name = "rust-analyzer";
      publisher = "rust-lang";
      version = "0.3.1386";
      sha256 = "qttgUVpoYNEg2+ArYxnEHwM4AbChQiB6/JW46+cq7/w=";
    };
  };
in
{
  options.oxc.desktop.vscode = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Visual Studio Code editor.";
    };

    support = {
      ai = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for AI tooling";
      };
      cpp = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for CPP development";
      };
      diff = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for diff tooling";
      };
      docker = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for Docker development";
      };
      editorconfig = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for EditorConfig";
      };
      elm = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Elm development";
      };
      fun = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for fun extensions like POWER MODEEEE";
      };
      github = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for GitHub tooling";
      };
      gitlens = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for the GitLens extension";
      };
      go = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Go development";
      };
      hugo = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Hugo development";
      };
      icons = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for additional icons support";
      };
      js = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for JavaScript development";
      };
      linux = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Linux development";
      };
      nix = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for Nix development";
      };
      php = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for PHP development";
      };
      prisma = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for Prisma ORM tooling";
      };
      python = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for Python development";
      };
      rust = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Rust development";
      };
      ssh = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for SSH tooling";
      };
      text = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for text editing";
      };
      tf = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for Terraform / OpenTofu";
      };
      vala = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable VS Code support for Vala development";
      };
      xml = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for XML editing";
      };
      yaml = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable VS Code support for YAML editing";
      };
    };
  };

  config =
    let
      inherit (config.oxc.desktop) vscode;
    in
    mkIf vscode.enable {
      environment.systemPackages = with pkgs; [
        (vscode-with-extensions.override {
          inherit (trunk) vscode;
          vscodeExtensions = with unstable.vscode-extensions;
            # globally enabled extensions
            lib.optionals vscode.support.cpp [ ms-vscode.cpptools ]
            ++ lib.optionals vscode.support.diff [ ryu1kn.partial-diff ]
            ++ lib.optionals vscode.support.docker [ ms-azuretools.vscode-docker ]
            ++ lib.optionals vscode.support.editorconfig [ editorconfig.editorconfig ]
            ++ lib.optionals vscode.support.elm [ elmtooling.elm-ls-vscode ]
            ++ lib.optionals vscode.support.github [ github.vscode-github-actions ]
            ++ lib.optionals vscode.support.gitlens [ eamodio.gitlens ]
            ++ lib.optionals vscode.support.go [ golang.go ]
            ++ lib.optionals vscode.support.icons [ vscode-icons-team.vscode-icons ]
            ++ lib.optionals vscode.support.js [ esbenp.prettier-vscode ]
            ++ lib.optionals vscode.support.linux [ coolbear.systemd-unit-file timonwong.shellcheck mads-hartmann.bash-ide-vscode ]
            ++ lib.optionals vscode.support.nix [ bbenoist.nix jnoortheen.nix-ide arrterian.nix-env-selector ]
            ++ lib.optionals vscode.support.php [ bmewburn.vscode-intelephense-client ]
            ++ lib.optionals vscode.support.prisma [ prisma.prisma ]
            ++ lib.optionals vscode.support.python [ ms-python.python ms-python.vscode-pylance ]
            ++ lib.optionals vscode.support.ssh [ ms-vscode-remote.remote-ssh ]
            ++ lib.optionals vscode.support.text [ streetsidesoftware.code-spell-checker yzhang.markdown-all-in-one ]
            ++ lib.optionals vscode.support.tf [ hashicorp.terraform ]
            ++ lib.optionals vscode.support.xml [ dotjoshjohnson.xml ]
            ++ lib.optionals vscode.support.yaml [ redhat.vscode-yaml ]

            # the most simple way to calculate a package's SHA256 is to simply
            # copy over an invalid SHA256 and the nixos-rebuild will fail,
            # with output for the specified and actual hash values.
            ++ (unstable.vscode-utils.extensionsFromVscodeMarketplace
              # globally enabled extensions
              [ ext.non-breaking-space-highlighter ]
            ++ lib.optionals vscode.support.cpp [ ]
            ++ lib.optionals vscode.support.diff [ ]
            ++ lib.optionals vscode.support.docker [ ]
            ++ lib.optionals vscode.support.editorconfig [ ]
            ++ lib.optionals vscode.support.elm [ ]
            ++ lib.optionals vscode.support.fun [ ext.vscode-power-mode ]
            ++ lib.optionals vscode.support.github [ ]
            ++ lib.optionals vscode.support.gitlens [ ]
            ++ lib.optionals vscode.support.go [ ]
            ++ lib.optionals vscode.support.hugo [ ext.language-hugo-vscode ]
            ++ lib.optionals vscode.support.icons [ ]
            ++ lib.optionals vscode.support.js [ ]
            ++ lib.optionals vscode.support.linux [ ext.linux-desktop-file ]
            ++ lib.optionals vscode.support.nix [ ]
            ++ lib.optionals vscode.support.php [ ]
            ++ lib.optionals vscode.support.python [ ]
            ++ lib.optionals vscode.support.rust [ ext.rust-analyzer ]
            ++ lib.optionals vscode.support.ssh [ ext.remote-ssh-edit ]
            # TODO: Determine root cause of manifest issues
            # ++ lib.optionals vscode.support.text [ext.simple-rst ext.vscode-mdx ext.vscode-mdx-preview]
            ++ lib.optionals vscode.support.xml [ ]
            ++ lib.optionals vscode.support.yaml [ ]
            )
          ;
        })
      ];

      # May require the service to be enable/started for the user
      # - systemctl --user enable auto-fix-vscode-server.service --now
    };
}
