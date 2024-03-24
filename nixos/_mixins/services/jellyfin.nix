{ pkgs, ... }: let
  jellyUserGroup = "jellyfin";
in
{
  users.users."${jellyUserGroup}" = {
    description = "Jellyfin Server";
    group = jellyUserGroup;
    isSystemUser = true;
    isNormalUser = false;
  };
  users.groups."${jellyUserGroup}" = {};

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = jellyUserGroup;
    group = jellyUserGroup;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}