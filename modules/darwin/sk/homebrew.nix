{ config, lib, ... }:
let
  cfg = config.oxc.sk.homebrew;
  inherit (lib) mkIf mkOption types;

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
    "oven-sh/bun/bun"
    "deno"
    "node"
  ];
  formattingBrews = [
  ];
  ciBrews = [
    "circleci"
    "codefresh-io/cli/codefresh"
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
  devCasks = [
    "altair-graphql-client"
    "cursor"
    "docker-desktop"
    "sequel-ace"
    "visual-studio-code"
  ];

  webCasks = [
    "google-chrome"
  ];

  casks = devCasks
    ++ webCasks;

  ##################################################
  # App Store apps managed by MAS
  ##################################################
  masApps = {
    XCode = 497799835;
  };
in
{
  options.sk = {
    homebrew.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Homebrew.";
    };
    homebrew.defaults = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the default Homebrew packages";
    };
  };

  config = mkIf cfg.sk.enable {
    environment.systemPath = [ "/opt/homebrew/bin" ];

    homebrew = { inherit masApps taps brews casks; };

    oxc.homebrew = {
      inherit (cfg.homebrew) enable defaults;
    };
  };
}
