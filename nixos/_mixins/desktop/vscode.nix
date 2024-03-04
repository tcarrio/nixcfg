args@{ pkgs, lib, ... }:
let
  codeServer = if builtins.hasAttr "codeServer" args then args.codeServer else { enable = false; };

  languages = if builtins.hasAttr "languages" args then args.languages else { };

  getLangOr = key: default: !!(if builtins.hasAttr key languages then languages [ key ] else default);

  getListIf = isEnabled: list: if isEnabled then list else [ ];

  ext = {
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

  g = {
    ai = getLangOr "ai" false;
    cpp = getLangOr "cpp" true;
    diff = getLangOr "diff" true;
    docker = getLangOr "docker" true;
    editorconfig = getLangOr "editorconfig" true;
    elm = getLangOr "elm" false;
    fun = getLangOr "fun" false;
    github = getLangOr "github" false;
    gitlens = getLangOr "gitlens" false;
    go = getLangOr "go" false;
    hugo = getLangOr "hugo" false;
    icons = getLangOr "icons" true;
    js = getLangOr "js" true;
    linux = getLangOr "linux" false;
    nix = getLangOr "nix" true;
    php = getLangOr "php" true;
    prisma = getLangOr "prisma" true;
    python = getLangOr "python" true;
    rust = getLangOr "rust" false;
    ssh = getLangOr "ssh" false;
    text = getLangOr "text" true;
    vala = getLangOr "vala" false;
    xml = getLangOr "xml" true;
    yaml = getLangOr "yaml" true;
  };
in
{
  imports = lib.optional codeServer.enable ../services/vscode-server.nix
  ;

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      inherit (trunk) vscode;
      vscodeExtensions = with unstable.vscode-extensions;
        # globally enabled extensions
        getListIf g.cpp [ ms-vscode.cpptools ]
        ++ getListIf g.diff [ ryu1kn.partial-diff ]
        ++ getListIf g.docker [ ms-azuretools.vscode-docker ]
        ++ getListIf g.editorconfig [ editorconfig.editorconfig ]
        ++ getListIf g.elm [ elmtooling.elm-ls-vscode ]
        ++ getListIf g.github [ github.vscode-github-actions ]
        ++ getListIf g.gitlens [ eamodio.gitlens ]
        ++ getListIf g.go [ golang.go ]
        ++ getListIf g.icons [ vscode-icons-team.vscode-icons ]
        ++ getListIf g.js [ esbenp.prettier-vscode ]
        ++ getListIf g.linux [ coolbear.systemd-unit-file timonwong.shellcheck mads-hartmann.bash-ide-vscode ]
        ++ getListIf g.nix [ bbenoist.nix jnoortheen.nix-ide ]
        ++ getListIf g.php [ bmewburn.vscode-intelephense-client ]
        ++ getListIf g.prisma [ prisma.prisma ]
        ++ getListIf g.python [ ms-python.python ms-python.vscode-pylance ]
        ++ getListIf g.ssh [ ms-vscode-remote.remote-ssh ]
        ++ getListIf g.text [ streetsidesoftware.code-spell-checker yzhang.markdown-all-in-one ]
        ++ getListIf g.xml [ dotjoshjohnson.xml ]
        ++ getListIf g.yaml [ redhat.vscode-yaml ]

        # the most simple way to calculate a package's SHA256 is to simply
        # copy over an invalid SHA256 and the nixos-rebuild will fail,
        # with output for the specified and actual hash values.
        ++ (pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace
          # globally enabled extensions
          [ ext.non-breaking-space-highlighter ]
        ++ getListIf g.cpp [ ]
        ++ getListIf g.diff [ ]
        ++ getListIf g.docker [ ]
        ++ getListIf g.editorconfig [ ]
        ++ getListIf g.elm [ ]
        ++ getListIf g.fun [ ext.vscode-power-mode ]
        ++ getListIf g.github [ ]
        ++ getListIf g.gitlens [ ]
        ++ getListIf g.go [ ]
        ++ getListIf g.hugo [ ext.language-hugo-vscode ]
        ++ getListIf g.icons [ ]
        ++ getListIf g.js [ ]
        ++ getListIf g.linux [ ext.linux-desktop-file ]
        ++ getListIf g.nix [ ]
        ++ getListIf g.php [ ]
        ++ getListIf g.python [ ]
        ++ getListIf g.rust [ ext.rust-analyzer ]
        ++ getListIf g.ssh [ ext.remote-ssh-edit ]
        # TODO: Determine root cause of manifest issues
        # ++ getListIf g.text [ext.simple-rst ext.vscode-mdx ext.vscode-mdx-preview]
        ++ getListIf g.xml [ ]
        ++ getListIf g.yaml [ ]
        )
      ;
    })
  ];

  # May require the service to be enable/started for the user
  # - systemctl --user enable auto-fix-vscode-server.service --now
}
