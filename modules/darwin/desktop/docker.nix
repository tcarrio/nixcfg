{ config, lib, ... }:
let
  cfg = config.oxc.docker;
in
{
  options.oxc.docker.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable Docker support for Darwin";
  };

  config = lib.mkIf cfg.enable {
    # We will utilize the Docker Desktop cask for support
    homebrew.casks = [ "docker-desktop" ];
  };
}
