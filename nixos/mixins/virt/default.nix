{ lib, config, pkgs, ... }:
{
  options.oxc = {
    containerisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable containerisation.";
      };
      engine = lib.mkOption {
        type = lib.types.enum [ "docker" "podman" ];
        default = "docker";
        description = "The containerisation tool to use.";
      };
      dockerCompatibility = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Docker compatibility mode for non-Docker engines.";
      };
      desktopApp = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the desktop application for managing the containers";
      };
    };
    virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable virtualisation.";
      };
    };
  };

  config = lib.mkIf config.oxc.containerisation.enable (
    let
      isDocker = config.oxc.containerisation.engine == "docker";
      isPodman = config.oxc.containerisation.engine == "podman";

      packages = {
        docker = with pkgs; [
          docker-compose
          lazydocker
        ];
        podman = with pkgs; [
          buildah
          distrobox
          fuse-overlayfs
          podman-compose
          podman-tui
        ] ++ lib.optionals config.oxc.containerisation.desktopApp [ podman-desktop ];
      };

      virtualisationPackages = lib.optionals config.oxc.virtualisation.enable (with pkgs; [
        unstable.quickemu
        xorg.xhost # for running X11 apps in distrobox
      ]);
    in
    {
      environment.systemPackages = packages.${config.oxc.containerisation.engine} ++ virtualisationPackages;

      virtualisation = {
        docker = lib.mkIf isDocker {
          enable = isDocker;
          storageDriver = lib.mkDefault "overlay2";
        };

        podman = lib.mkIf isPodman {
          defaultNetwork.settings = {
            dns_enabled = true;
          };
          dockerCompat = config.oxc.containerisation.dockerCompatibility;
          enable = isPodman;
          enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
        };
      };
    }
  );
}
