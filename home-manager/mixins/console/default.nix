# Console profile: composes the oxc.console library modules with personal
# values. All programs.* configuration flows through the library modules;
# this file only sets enables, options, and personal data.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # neovim/tmux/worktree-cli are imported via the library module set
  ];

  oxc.console = {
    git.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    modern-unix = {
      enable = lib.mkDefault true;
      extras = lib.mkDefault true;
    };
    tools.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    worktree-cli.enable = lib.mkDefault true;
    asciinema.enable = lib.mkDefault true;
    charm-freeze.enable = lib.mkDefault false;
    zeit.enable = lib.mkDefault true;
  };

  # Personal options layered on the library modules
  oxc.console.fish = {
    aliases = {
      diff = "diffr";
      ip = lib.mkDefault "ip --color --brief";
      top = "htop";
      tree = "eza --tree";
      # Ensures that gh auth uses config that will not conflict
      # with settings in the programs.gh.settings block
      gh-auth = "gh auth login -p ssh -h github.com -w --skip-ssh-key";

      tailscale-ipv4 = "tailscale status --json 2>/dev/null | jq -r '.TailscaleIPs[] | select(. | startswith(\"100.\"))'";
      tailscale-ipv6 = "tailscale status --json 2>/dev/null | jq -r '.TailscaleIPs[] | select(. | startswith(\"100.\") | not)'";
      tailscale-ip = "tailscale-ipv4"; # 🤷
    };

    functions =
      let
        doCurl = type: url: "$(curl -L \"${url}\" 2>/dev/null | ${type}sum | awk '{print $1}')";
        makeSriHasher = type: content: "nix-hash --type ${type} --to-sri ${content}";
        makeSriUrlHasher = url: type: makeSriHasher type (doCurl type url);
        makeSriUrlHasherFishFunction = makeSriUrlHasher "$argv[1]";
      in
      {
        dev = ''
          if [ -d $HOME/0xc/nixcfg ]
            nix develop $HOME/0xc/nixcfg#$argv[1]
          else
            nix develop github:( \\
              git remote -v \\
              | grep '(push)' \\
              | awk '{print $2}' \\
              | cut -d ':' -f 2 \\
              | rev \\
              | ${pkgs.gnused}/bin/sed 's/tig.//' \\
              | rev \\
              )#$argv[1];
          end
        '';
        is-number = ''
          string match --quiet --regex "^\\d+\\$" $argv[1]
        '';
        deploy-nuc = "is-number $argv[1] && nixos-rebuild --fast --flake $HOME/0xc/nixcfg#nuc$argv[1] --target-host root@192.168.40.20$argv[1] $argv[2..]";

        sriMd5Url = makeSriUrlHasherFishFunction "md5";
        sriSha1Url = makeSriUrlHasherFishFunction "sha1";
        sriSha256Url = makeSriUrlHasherFishFunction "sha256";
        sriSha512Url = makeSriUrlHasherFishFunction "sha512";
      };
  };

  # Neofetch config (fastfetch replaced neofetch; config remains compatible)
  home.file."${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ./neofetch.conf;

  home.sessionVariables = {
    PAGER = "less";
  };

  # Historical defaults preserved for internal hosts
  oxc.console.atuin.enable = lib.mkDefault true;
  oxc.github.enable = lib.mkDefault true;
  oxc.github.cli.enable = lib.mkDefault true;
  oxc.github.dash.enable = lib.mkDefault true;
}
