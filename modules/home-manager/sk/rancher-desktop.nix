{ config, lib, ... }:
let
  rancherDesktopEnabled = config.sk.containerization.rancher-desktop;
  inherit (config.home) homeDirectory;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  options.sk.containerization.rancher-desktop = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable Rancher Desktop integration";
  };

  config = lib.mkIf rancherDesktopEnabled {
    home.file = {
      ".docker/cli-plugins/docker-buildx".source = mkOutOfStoreSymlink "${homeDirectory}/.rd/bin/docker-buildx";
      ".docker/cli-plugins/docker-compose".source = mkOutOfStoreSymlink "${homeDirectory}/.rd/bin/docker-compose";
      ".docker/cli-plugins/docker-credential-ecr-login".source = mkOutOfStoreSymlink "${homeDirectory}/.rd/bin/docker-credential-ecr-login";
      ".docker/cli-plugins/docker-credential-none".source = mkOutOfStoreSymlink "${homeDirectory}/.rd/bin/docker-credential-none";
      ".docker/cli-plugins/docker-credential-osxkeychain".source = mkOutOfStoreSymlink "${homeDirectory}/.rd/bin/docker-credential-osxkeychain";
    };
  };
}
