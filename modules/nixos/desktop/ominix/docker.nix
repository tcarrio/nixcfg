# see install/docker.sh
{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    virtualisation.docker.enable = lib.mkOverride 999 true;

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    environment.etc."docker/daemon.json".text = builtins.toJSON {
      "log-driver" = "json-file";
      "log-opts" = {
        "max-size" = "10m";
        "max-file" = "5";
      };
    };
  };
}
