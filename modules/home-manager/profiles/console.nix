# Console profile: composes the oxc.console library modules with the oxc
# preset values — the full developer console (git+aliases, fish+functions,
# direnv, modern-unix, tools, neovim, tmux, worktree-cli, atuin, gh).
# Programs.* configuration flows through the library modules; this profile
# only sets enables and preset options.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.profiles.console;
in
{
  options.oxc.profiles.console = {
    enable = lib.mkEnableOption "the oxc console profile (developer console preset)";
  };

  config = lib.mkIf cfg.enable {
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

    # Preset options layered on the library modules
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

    oxc.console.atuin.enable = lib.mkDefault true;
    oxc.github.enable = lib.mkDefault true;
    oxc.github.cli.enable = lib.mkDefault true;
    oxc.github.dash.enable = lib.mkDefault true;
  };
}
