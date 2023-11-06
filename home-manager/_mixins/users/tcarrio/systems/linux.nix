{ username, ... }: {
  imports = [
    ./audio-recorder.nix
    ./celluloid.nix
    ./dconf-editor.nix
    ./gnome-sound-recorder.nix
    ./tilix.nix
    ./emote.nix
  ];

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/0xc                           0755 ${username} users - -"
    "d /home/${username}/Code                          0755 ${username} users - -"
    "d /home/${username}/Developer                     0750 ${username} users - -"
  ];
}