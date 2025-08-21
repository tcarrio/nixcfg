{ config, ... }: {
  home.file.".local/share/applications/nixos".source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/applications";
  home.file.".local/share/applications/home-manager".source = config.lib.file.mkOutOfStoreSymlink "${config.home}/.nix-profile/share/applications/";
}