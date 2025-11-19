{ config, ... }: {
  # The following lines allow `wofi` to detect applications installed by the system and home-manager configurations
  # by generating symbolic links to the root directories of the respective component's application directories.
  home.file.".local/share/applications/nixos".source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/applications";
  home.file.".local/share/applications/home-manager".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/share/applications/";
}