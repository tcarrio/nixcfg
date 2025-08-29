{ config, lib, ... }:
let
  cfg = config.oxc.homebrew;

  # SECTION: homebrew package defaults
  containerBrews = [ ]; # "docker" "docker-compose" "colima";
  toolingBrews = [
    # "asdf"
    "awscli"
    "ca-certificates"
    "git-crypt"
    "git"
    "go-task"
    "jq"
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
    "dive"
    "editorconfig"
    "freetype"
    "fswatch"
    "gd"
    "gettext"
    "ghostscript"
    "glib"
    "gnu-getopt"
    "gnupg"
    "gnutls"
    "go"
    "gpatch"
    "graphite2"
    "graphviz"
    "hadolint"
    "k6"
    "krb5"
    "mkcert"
    "ncdu"
    "pandoc"
    "pango"
    "pkg-config"
    "portaudio"
    "protobuf"
    "protobuf@21"
    "re2c"
    "readline"
    "redis"
    "ripgrep"
    "rustup"
    "sops"
    "sqlite"
    "stern"
    "unixodbc"
    "unzip"
    "wget"
    "xz"
    "yarn"
    "zlib"
  ];
  defaultTaps = [
    "codefresh-io/cli"
    "oven-sh/bun"
  ];

  defaultBrews = containerBrews
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

  defaultCasks = [
    "amethyst"
    "cursor"
    "docker-desktop"
    "gimp"
    "google-chrome"
    "insomnia"
    "iterm2"
    "secretive"
    "sequel-ace"
    "tailscale-app"
    "visual-studio-code"
    "zed"
    "zen"
  ];
in {
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

  config.homebrew = {
    enable = cfg.enable;

    # the following sets up Homebrew to NEVER update implicitly
    # to update brew itself, use `brew upgrade`
    # to update brew packages, use `brew update`
    global.autoUpdate = false;
    onActivation.autoUpdate = false;

    taps = defaultTaps;
    brews = defaultBrews;
    casks = defaultCasks;
  };
}
