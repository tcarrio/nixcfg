{ lib, hostname, username, ... }: {
  imports = [ ]
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;

  home = {
    file.".face".source = ./face.png;
    #file."Development/debian/.envrc".text = "export DEB_VENDOR=Debian";
    #file."Development/ubuntu/.envrc".text = "export DEB_VENDOR=Ubuntu";
    file.".ssh/config".text = "
      Host github.com
        HostName github.com
        User git
    ";
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
    sessionVariables = {
      # ...
    };
  };
  programs = {
    git = {
      userEmail = "tom@carrio.dev";
      userName = "Tom Carrio";
      # signing = {
      #   key = "DEADBEEF";
      #   signByDefault = true;
      # };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/0xc                           0755 ${username} users - -"
    "d /home/${username}/Code                          0755 ${username} users - -"
    "d /home/${username}/Games                         0755 ${username} users - -"
    "d /home/${username}/Quickemu/nixos-console        0755 ${username} users - -"
    "d /home/${username}/Quickemu/nixos-desktop        0755 ${username} users - -"
    "d /home/${username}/Quickemu/nixos-nuc            0755 ${username} users - -"
    "d /home/${username}/Studio/OBS/config/obs-studio/ 0755 ${username} users - -"
    "d /home/${username}/Syncthing                     0755 ${username} users - -"
    "d /home/${username}/Websites                      0755 ${username} users - -"
    "L+ /home/${username}/.config/obs-studio/          -    -           -     - /home/${username}/Studio/OBS/config/obs-studio/"
  ];
}
