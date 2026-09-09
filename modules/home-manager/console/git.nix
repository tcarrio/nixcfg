{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.git;

  # The alias preset carried from the console mixin — a personal shorthand
  # vocabulary built over years; available as the default so existing hosts
  # keep it, overridable wholesale by consumers.
  aliasPreset = {
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
    # gets latest "shared root" commit
    sr = "merge-base HEAD";
    aa = "!git a $(git rd)";
    rsa = "!git rs $(git rd)";
    fa = "f --all";
    cob = "co -b";
    rh = "rs --hard";
    rho = "!git rh $(git bdr)/$(git bn)";
    # shows commit history
    lg = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
    lgc = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    # amend
    am = "!git cm --amend --no-edit --date=\"$(date +'%Y %D')\"";
    # push to origin HEAD
    poh = "!git p $(git bdr) HEAD";
    # push remote branch
    prb = "!gitprb() { local remote=\"$1\"; shift; test -z \"$remote\" && remote=\"$(git bdr)\"; test -z \"$remote\" && remote=\"origin\"; test -n \"$remote\" && git p $remote $(git bn) $@; }; gitprb";
    # short-hand for "push head"
    ph = "prb";
    # force with lease, please, if you would
    pf = "!git prb $(git bdr) --force-with-lease";
    # FORCEEEE
    pff = "!git prb $(git bdr) --force";
    # push and open pr
    ppr = "!git poh; !git pr";
    # open pr
    pr = "!gh pr create";
    # squash it
    sq = "!gitsq() { git rb -i $(git sr $1) $2; }; gitsq";
    # generate patch
    gp = "!gitgenpatch() { target=$1; git format-patch $target --stdout | ${pkgs.gnused}/bin/sed -rn '/^diff --git/,\$p' | head -n -3; }; gitgenpatch";

    # default remote configurations
    sdr = "config checkout.defaultRemote";
    cdr = "!gitcdr() { git config --get checkout.defaultRemote || printf 'origin' ; }; gitcdr";
    bdr = "!gitbdr() { git config branch.$(git bn).remote || git cdr; }; gitbdr";

    # default trunk branch configurations
    tb = "!gittb() { git ls-remote --symref origin HEAD | grep 'refs/heads/' | ${pkgs.gnused}/bin/sed -rn 's#.*refs/heads/([a-zA-Z0-9]+).*#\\1#p'; }; gittb";

    # checkout utility to checkout the local trunk branch of the repo
    cot = "!git co $(git tb)";
    rbot = "!git rebase $(git bdr)/$(git tb)";

    # short-hands for ignoring and unignoring files without .gitignore
    ignore = "update-index --assume-unchanged";
    ig = "ignore";
    unignore = "update-index --no-assume-unchanged";
    unig = "unignore";
    ignored = "!gitignored() { git ls-files -v | grep \"^[[:lower:]]\"; }; gitignored";
    ls-ig = "ignored";

    # git-absord shorthands
    ab = "absorb";
    abr = "git absorb --and-rebase";
  };
in
{
  options.oxc.console.git = {
    enable = lib.mkEnableOption "git with the oxc alias preset and base settings";

    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default git user.name; null leaves it unset (host/profile supplies it).";
    };

    userEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default git user.email; null leaves it unset (host/profile supplies it).";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = aliasPreset;
      defaultText = lib.literalExpression "oxc alias preset";
      description = "git aliases merged into programs.git.settings.alias";
    };

    ignores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "*.log"
        "*.out"
        ".DS_Store"
        "dist/"
        "result"
      ];
      description = "Global gitignore patterns";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra programs.git.settings to merge";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings =
        {
          alias = cfg.aliases;
          push.default = "matching";
          pull = {
            rebase = true;
            ff = "only";
          };
          init.defaultBranch = "main";
        }
        // cfg.settings
        // (lib.optionalAttrs (cfg.userName != null) { user.name = cfg.userName; })
        // (lib.optionalAttrs (cfg.userEmail != null) { user.email = cfg.userEmail; });
      ignores = cfg.ignores;
    };
  };
}
