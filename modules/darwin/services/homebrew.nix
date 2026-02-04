{ config, lib, ... }:
let
  cfg = config.oxc.homebrew;


  ##################################################
  # Brew taps
  ##################################################
  taps = [
    "codefresh-io/cli"
    "oven-sh/bun"
  ];


  ##################################################
  # Brew formulae
  ##################################################
  containerBrews = [ ]; # "docker" "docker-compose" "colima";
  toolingBrews = [
    "awscli"
    "ca-certificates"
    "go-task"
    "openssl"
  ];
  pythonBrews = [
    "bpython"
    "pyenv"
    "python@3.10"
    "python@3.11"
    "python@3.12"
    "python@3.9"
    "six"
  ];
  buildBrews = [
    "automake"
    "bison"
    "cmake"
  ];
  bashBrews = [
    "coreutils"
    "bats-core"
    "shellcheck"
    "shfmt"
  ];
  jsBrews = [
    "bun"
    "deno"
    "node"
  ];
  formattingBrews = [
  ];
  ciBrews = [
    "circleci"
    "codefresh"
  ];
  cfBrews = [
    "cloudflared"
    "flarectl"
  ];
  k8sBrews = [
    "k9s"
    "kubernetes-cli"
  ];
  phpBrews = [
    "m4"
    "ninja"
    "icu4c"
    "imagemagick"
    "libedit"
    "libiconv"
    "libjpeg"
    "libpng"
    "libsodium"
    "libtool"
    "libxml2"
    "libxslt"
    "libyaml"
    "libzip"
    "pcre"
  ];
  postgresBrews = [
    "postgresql"
    "postgresql@14"
  ];
  iacBrews = [
    "ansible"
    "terraform"
    "terragrunt"
    "terraformer"
  ];
  dataScienceBrews = [
    "r"
  ];
  baseBrews = [
    "autoconf"
    "brotli"
    "c-ares"
    "conftest"
    "curl"
    "dbus"
    "editorconfig"
    "freetype"
    "fswatch"
    "gd"
    "gettext"
    "ghostscript"
    "glib"
    "gnu-getopt"
    "gnutls"
    "go"
    "gpatch"
    "graphite2"
    "graphviz"
    "hadolint"
    "k6"
    "krb5"
    "mkcert"
    "pandoc"
    "pango"
    "pkg-config"
    "portaudio"
    "protobuf"
    "protobuf@21"
    "re2c"
    "readline"
    "redis"
    "rustup"
    "sops"
    "sqlite"
    "stern"
    "unixodbc"
    "xz"
    "yarn"
    "zlib"
  ];

  brews = containerBrews
    ++ toolingBrews
    ++ pythonBrews
    ++ buildBrews
    ++ bashBrews
    ++ jsBrews
    ++ formattingBrews
    ++ ciBrews
    ++ cfBrews
    ++ k8sBrews
    ++ phpBrews
    ++ postgresBrews
    ++ iacBrews
    ++ dataScienceBrews
    ++ baseBrews;

  ##################################################
  # Brew casks
  ##################################################
  securityCasks = [
    "secretive"
    "tailscale-app"
  ];

  devCasks = [
    "alacritty"
    "altair-graphql-client"
    "atuin-desktop"
    "ghostty"
    "zed"
  ];

  webCasks = [
    "google-chrome"
    "zen"
  ];

  desktopCasks = [
    "amethyst"
    "gimp"
    "logitune"
    "notunes"
    "signal"
    "sol"
  ];

  casks = securityCasks
    ++ devCasks
    ++ webCasks
    ++ desktopCasks;


  ##################################################
  # App Store apps managed by MAS
  ##################################################
  masApps = {
    Flow = 1423210932;
    XCode = 497799835;
  };

  configuredDefaults =
    if cfg.defaults
    then { inherit masApps taps brews casks; }
    else { };
in
{
  options.oxc.homebrew = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Homebrew package manager";
    };
    # TODO: Implement conditionality of this option
    defaults = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable my default set of packages for Homebrew";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPath = [ "/opt/homebrew/bin" ];

    homebrew = {
      enable = true;

      # the following sets up Homebrew to NEVER update implicitly
      # to update brew itself, use `brew upgrade`
      # to update brew packages, use `brew update`
      global.autoUpdate = false;
      onActivation.autoUpdate = false;
    } // configuredDefaults;
  };
}
