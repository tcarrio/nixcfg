{ pkgs, ... }: {
  imports = [
    ../services/sane.nix
  ];

  oxc.services.flatpak.enable = true;

  # Add additional apps and include Yaru for syntax highlighting
  environment.systemPackages = with pkgs; [
    appeditor
    celluloid
    gthumb
    formatter
    usbimager
    yaru-theme
  ];

  # Add GNOME Disks, Pantheon Tweaks and Seahorse
  programs = {
    gnome-disks.enable = true;
    pantheon-tweaks.enable = true;
    seahorse.enable = true;
  };

  systemd.services.configure-appcenter-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
    '';
  };
}
