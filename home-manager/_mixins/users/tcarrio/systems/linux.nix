{ username, ... }: {
  imports = [
    ../../../desktop/audio-recorder.nix
    ../../../desktop/celluloid.nix
    ../../../desktop/dconf-editor.nix
    ../../../desktop/gnome-sound-recorder.nix
    ../../../desktop/tilix.nix
    ../../../desktop/emote.nix
  ];

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/0xc                           0755 ${username} users - -"
    "d /home/${username}/Code                          0755 ${username} users - -"
    "d /home/${username}/Developer                     0750 ${username} users - -"
  ];
}