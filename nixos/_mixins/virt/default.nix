{ desktop, lib, ... }:
{
  options.oxc = {
    containerization = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable containerization.";
      };
      engine = lib.mkOption {
        type = lib.types.enum ["docker" "podman"];
        default = "docker";
        description = "The containerization tool to use.";
      };
      dockerCompatibility = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Docker compatibility mode for non-Docker engines.";
      };
    };
    virtualization = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable virtualization.";
      };
    };
  };

  config = lib.mkIf config.oxc.containerization.enable (
    let
      isDocker = config.oxc.containerization.engine == "docker";
      isPodman = config.oxc.containerization.engine == "podman";

      packages = {
        docker = with pkgs; [
          docker-compose
        ];
        podman = with pkgs; [
          buildah
          distrobox
          fuse-overlayfs
          podman-compose
          podman-tui
        ];
      };

      virtualizationPackages = if config.oxc.virtualization.enable then (with pkgs; [
        unstable.quickemu
        xorg.xhost # for running X11 apps in distrobox
      ]) else [];
    in {
      environment.systemPackages = packages.${config.oxc.containerization.engine} ++ virtualizationPackages;

      virtualization = {
        docker = lib.mkIf isDocker {
          enable = isDocker;
          storageDriver = lib.mkDefault "overlay2";
        };

        podman = lib.mkIf isPodman {
          defaultNetwork.settings = {
            dns_enabled = true;
          };
          dockerCompat = config.oxc.containerization.dockerCompatibility;
          enable = isPodman;
          enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
        };
      };
    };
  );
}
