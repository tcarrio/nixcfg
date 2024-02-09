{ username, ... }: {
  imports = [
    ../../../desktop/audio-recorder.nix
    ../../../desktop/celluloid.nix
    ../../../desktop/dconf-editor.nix
    ../../../desktop/gnome-sound-recorder.nix
    ../../../desktop/tilix.nix
    ../../../desktop/emote.nix
  ];

  home = {
    file."Quickemu/nixos-console.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-console/disk.qcow2"
        disk_size="96G"
        iso="nixos-console/nixos.iso"
    '';
    file."Quickemu/nixos-desktop.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-desktop/disk.qcow2"
        disk_size="96G"
        iso="nixos-desktop/nixos.iso"
    '';
    file."Quickemu/nixos-nuc.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-nuc/disk.qcow2"
        disk_size="96G"
        iso="nixos-nuc/nixos.iso"
    '';
  };

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/0xc                           0755 ${username} users - -"
    "d /home/${username}/Code                          0755 ${username} users - -"
    "d /home/${username}/Developer                     0750 ${username} users - -"
  ];
}
