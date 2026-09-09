{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.modern-unix;

  # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
  coreTools = with pkgs; [
    bottom # modern `top`
    dua # modern `du`
    duf # modern `df`
    dust # modern `du`
    entr # modern `watch`
    fd # modern `find`
    fzf # fuzzy finder
    htop # process viewer
    ripgrep # modern `grep`
    wget # downloader
  ];

  extraTools = with pkgs; [
    asciinema # terminal recorder
    breezy # terminal bzr client
    chafa # terminal image viewer
    dconf2nix # Nix code from dconf files
    diffr # modern `diff`
    difftastic # modern `diff`
    fastfetch # terminal system info
    ffmpeg-headless # terminal video encoder
    glow # terminal Markdown renderer
    gping # modern `ping`
    hexyl # modern `hexedit`
    hyperfine # benchmarking
    jpegoptim # JPEG optimizer
    jiq # modern `jq`
    lazygit # terminal git client
    nixpkgs-review # Nix code review
    nurl # Nix URL fetcher
    nyancat # rainbow feline
    optipng # PNG optimizer
    page # pager
    procs # modern `ps`
    quilt # patch manager
    tldr # modern `man`
    tokei # SLOC counter
    yq-go # `jq` for YAML
  ];
in
{
  options.oxc.console.modern-unix = {
    enable = lib.mkEnableOption "the modern-unix CLI toolset";

    extras = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include the extended tool list beyond the core set";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages appended to the toolset";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      coreTools
      ++ (lib.optionals cfg.extras extraTools)
      ++ cfg.packages;
  };
}
