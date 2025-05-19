_:
let
  containerBrews = [ ]; # "docker" "docker-compose" "colima" ];
  toolingBrews = [
    "asdf"
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
    "pyyaml"
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
in
{
  homebrew = {
    taps = [
      "codefresh-io/cli"
      "oven-sh/bun"
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

    casks = [
      "alfred"
      "amethyst"
      "cursor"
      "docker"
      "insomnia"
      "secretive"
      "sequel-ace"
      "zed"
    ];
  };
}
