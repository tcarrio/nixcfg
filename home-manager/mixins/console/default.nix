{ config, pkgs, lib, ... }: {
  imports = [
    ./neovim.nix
    ./tmux.nix
  ];

  home = {
    file = {
      "${config.xdg.configHome}/neofetch/config.conf".text = builtins.readFile ./neofetch.conf;
    };

    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs; [
      asciinema # Terminal recorder
      breezy # Terminal bzr client
      chafa # Terminal image viewer
      dconf2nix # Nix code from Dconf files
      diffr # Modern Unix `diff`
      difftastic # Modern Unix `diff`
      dua # Modern Unix `du`
      duf # Modern Unix `df`
      du-dust # Modern Unix `du`
      entr # Modern Unix `watch`
      fd # Modern Unix `find`
      ffmpeg-headless # Terminal video encoder
      fzf # Command-line fuzzy finder
      glow # Terminal Markdown renderer
      gping # Modern Unix `ping`
      hexyl # Modern Unix `hexedit`
      hyperfine # Terminal benchmarking
      jpegoptim # Terminal JPEG optimizer
      jiq # Modern Unix `jq`
      lazygit # Terminal Git client
      neofetch # Terminal system info
      nixpkgs-review # Nix code review
      nurl # Nix URL fetcher
      nyancat # Terminal rainbow spewing feline
      optipng # Terminal PNG optimizer
      page # Modern pager
      procs # Modern Unix `ps`
      quilt # Terminal patch manager
      ripgrep # Modern Unix `grep`
      tldr # Modern Unix `man`
      tokei # Modern Unix `wc` for code
      wget # Terminal downloader
      yq-go # Terminal `jq` for YAML
    ];

    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  oxc.console.atuin.enable = lib.mkDefault true;

  programs = {
    bottom = {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = "auto";
    };
    fish = {
      enable = true;
      shellAliases = {
        diff = "diffr";
        glow = "glow --pager";
        htop = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        ip = "ip --color --brief";
        top = "btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
        tree = "eza --tree";
      };
      functions =
        let
          doCurl = type: url: "$(curl -L \"${url}\" 2>/dev/null | ${type}sum | awk '{print $1}')";
          makeSriHasher = type: content: "nix-hash --type ${type} --to-sri ${content}";
          makeSriUrlHasher = url: type: makeSriHasher type (doCurl type url);
          makeSriUrlHasherFishFunction = makeSriUrlHasher "$argv[1]";
        in
        {
          shell = ''
            nix develop $HOME/0xc/nixcfg#$argv[1] || nix develop $HOME/0xc/nixcfg#( \
              git remote -v \
                | grep '(push)' \
                | awk '{print $2}' \
                | cut -d ':' -f 2 \
                | rev \
                | sed 's/tig.//' \
                | rev \
            )
          '';
          is-number = ''
            string match --quiet --regex "^\d+\$" $argv[1]
          '';
          deploy-nuc = "is-number $argv[1] && nixos-rebuild --fast --flake $HOME/0xc/nixcfg#nuc$argv[1] --target-host root@192.168.40.20$argv[1] $argv[2..]";

          sriMd5Url = makeSriUrlHasherFishFunction "md5";
          sriSha1Url = makeSriUrlHasherFishFunction "sha1";
          sriSha256Url = makeSriUrlHasherFishFunction "sha256";
          sriSha512Url = makeSriUrlHasherFishFunction "sha512";
        };
      plugins = with pkgs.fishPlugins; [
        { name = "foreign-env"; inherit (foreign-env) src; }
        { name = "fzf"; inherit (fzf-fish) src; }
      ];
    };
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      enable = true;
      delta = {
        enable = false;
        # enable = true;
        # options = {
        #   features = "decorations";
        #   navigate = true;
        #   line-numbers = true;
        #   side-by-side = true;
        #   syntax-theme = "GitHub";
        # };
      };
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        a = "add";
        f = "fetch";
        p = "push";
        co = "checkout";
        cm = "commit";
        st = "status";
        br = "branch";
        rs = "reset";
        rb = "rebase";
        rbc = "rebase --continue";
        d = "diff";
        ds = "d --staged";
        # branch name
        bn = "br --show-current";
        # gets root directory
        rd = "rev-parse --show-toplevel";
        # gets latest shared commit
        sr = "merge-base HEAD";
        aa = "!git a $(git rd)";
        rsa = "!git rs $(git rd)";
        fa = "f --all";
        # shows commit history
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        # amend
        am = "!git cm --amend --no-edit --date=\"$(date +'%Y %D')\"";
        # push to origin HEAD
        poh = "p origin HEAD";
        # push remote branch- defaults to 'origin' but can accept a remote name
        prb = "!gitprb() { local remote=\"$1\"; test -z \"$remote\" && remote=\"$(git cdr)\"; test -z \"$remote\" && remote=\"origin\"; test -n \"$remote\" && git p $remote $(git bn); }; gitprb";
        # force with lease, please, if you would
        pf = "!git prb $(git cdr || echo -n 'origin') --force-with-lease";
        # FORCEEEE
        pff = "!git prb $(git cdr || echo -n 'origin') --force";
        # push and open pr
        ppr = "!git poh; !git pr";
        # open pr
        pr = "!gh pr create";
        # squash it
        sq = "!gitsq() { git rb -i $(git sr $1) $2; }; gitsq";
        # generate patch
        gp = "!gitgenpatch() { target=$1; git format-patch $target --stdout | sed -n -e '/^diff --git/,$p' | head -n -3; }; gitgenpatch";
        cob = "co -b";
        rh = "rs --hard";
        rho = "!git rh origin/$(git bn)";

        # default remote configurations
        sdr = "config checkout.defaultRemote";
        cdr = "!gitcdr() { git config --get checkout.defaultRemote || printf 'origin' ; }; gitcdr";

        # short-hands for ignoring and unignoring files without .gitignore
        ignore = "update-index --assume-unchanged";
        ig = "ignore";
        unignore = "update-index --no-assume-unchanged";
        unig = "unignore";
        ignored = "!git ls-files -v | grep \"^[[:lower:]]\"";
        ls-ig = "ignored";
      };
      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
          ff = "only";
        };
        init = {
          defaultBranch = "main";
        };
      };
      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
    gpg.enable = true;
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      settings = {
        colorscheme = "simple";
        diffgutter = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
      };
    };
    powerline-go = {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        max-width = 60;
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
