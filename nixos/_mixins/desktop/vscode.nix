{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = master.vscode;
      vscodeExtensions = with unstable.vscode-extensions; [
        bbenoist.nix
        coolbear.systemd-unit-file
        dotjoshjohnson.xml
        eamodio.gitlens
        editorconfig.editorconfig
        elmtooling.elm-ls-vscode
        esbenp.prettier-vscode
        github.vscode-github-actions
        golang.go
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        ms-azuretools.vscode-docker
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-ssh
        ms-vscode.cpptools
        redhat.vscode-yaml
        ryu1kn.partial-diff
        streetsidesoftware.code-spell-checker
        timonwong.shellcheck
        vscode-icons-team.vscode-icons
        yzhang.markdown-all-in-one
      ]
      # the most simple way to calculate a package's SHA256 is to simply
      # copy over an invalid SHA256 and the nixos-rebuild will fail,
      # with output for the specified and actual hash values.
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "language-hugo-vscode";
          publisher = "budparr";
          version = "1.3.1";
          sha256 = "sha256-9dp8/gLAb8OJnmsLVbOAKAYZ5whavPW2Ak+WhLqEbJk=";
        }
        {
          name = "linux-desktop-file";
          publisher = "nico-castell";
          version = "0.0.21";
          sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
        }
        {
          name = "non-breaking-space-highlighter";
          publisher = "viktorzetterstrom";
          version = "0.0.3";
          sha256 = "sha256-t+iRBVN/Cw/eeakRzATCsV8noC2Wb6rnbZj7tcZJ/ew=";
        }
        {
          name = "pubspec-assist";
          publisher = "jeroen-meijer";
          version = "2.3.2";
          sha256 = "sha256-+Mkcbeq7b+vkuf2/LYT10mj46sULixLNKGpCEk1Eu/0=";
        }
        {
          name = "simple-rst";
          publisher = "trond-snekvik";
          version = "1.5.3";
          sha256 = "sha256-0gPqckwzDptpzzg1tP4I9WQfrXlflO+G0KcAK5pEie8=";
        }
        {
          name = "vala";
          publisher = "prince781";
          version = "1.0.8";
          sha256 = "sha256-IuIb7vLNiE3rzVHOsjInaYLzNYORbwabQq0bfaPLlqc=";
        }
        {
          name = "vscode-front-matter";
          publisher = "eliostruyf";
          version = "8.4.0";
          sha256 = "sha256-L0PbZ4HxJAlxkwVcZe+kBGS87yzg0pZl89PU0aUVYzY=";
        }
        {
          name = "vscode-mdx";
          publisher = "unifiedjs";
          version = "1.4.0";
          sha256 = "sha256-qqqq0QKTR0ZCLdPltsnQh5eTqGOh9fV1OSOZMjj4xXg=";
        }
        {
          name = "vscode-mdx-preview";
          publisher = "xyc";
          version = "0.3.3";
          sha256 = "sha256-OKwEqkUEjHIJrbi9S2v2nJrZchYByDU6cXHAn7uhxcQ=";
        }
        {
          name = "vscode-power-mode";
          publisher = "hoovercj";
          version = "3.0.2";
          sha256 = "sha256-ZE+Dlq0mwyzr4nWL9v+JG00Gllj2dYwL2r9jUPQ8umQ=";
        }
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
        {
          name = "rust-analyzer";
          publisher = "rust-lang";
          version = "0.3.1386";
          sha256 = "qttgUVpoYNEg2+ArYxnEHwM4AbChQiB6/JW46+cq7/w=";
        }
      ];
    })
  ];

  services.vscode-server.enable = true;
  # May require the service to be enable/started for the user
  # - systemctl --user enable auto-fix-vscode-server.service --now
}
