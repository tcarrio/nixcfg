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
  toolingBrews = [
    "ca-certificates"
  ];

  brews = toolingBrews;

  ##################################################
  # Brew casks
  ##################################################
  securityCasks = [
    "secretive"
    "tailscale-app"
  ];

  devCasks = [
    "atuin-desktop"
    "ghostty"
    "zed"
  ];

  webCasks = [
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
