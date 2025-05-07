{ config, pkgs, lib, inputs, system, platform, stateVersion, ... }@args:

let
  zenixbookPath = "/etc/zenixbook";

  # TODO: Use args.hostname
  hostname = lib.mkDefault "zenixbook";

  zenBrowserPackage = inputs.zen-browser.packages."${system}".specific;

  notifyUsersScript = pkgs.writeScript "notify-users.sh" ''
    set -eu

    title="$1"
    body="$2"

    users=$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}' | while read session; do
      loginctl show-session "$session" -p Name | cut -d'=' -f2
    done | sort -u)

    for user in $users; do
      ${pkgs.sudo}/bin/sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$user")/bus" \
        ${pkgs.libnotify}/bin/notify-send "$title" "$body"
    done
  '';

  updateZenixbookGitScript = pkgs.writeScript "update-git.sh" ''
    set -eu
    
    # Update zenixbook configs
    ${pkgs.git}/bin/git -C ${zenixbookPath} reset --hard
    ${pkgs.git}/bin/git -C ${zenixbookPath} clean -fd
    ${pkgs.git}/bin/git -C ${zenixbookPath} pull --rebase
  '';

  updateSystemFlatpaksScript = pkgs.writeScript "update-system-flatpaks.sh" ''
    set -eu

    # Update Flatpaks
    ${pkgs.coreutils-full}/bin/nice -n 19 \
      ${pkgs.util-linux}/bin/ionice -c 3 \
      ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
  '';

  updateNixosConfigScript = pkgs.writeScript "update-nixos-config.sh" ''
    set -eu

    ${pkgs.coreutils-full}/bin/nice -n 19 \
      ${pkgs.util-linux}/bin/ionice -c 3 \
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake ${zenixbookPath}#${hostname}
  '';
in
{
  zramSwap.enable = true;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  xdg.portal.enable = true;

  # Configure host
  networking.hostName = hostname;
  nixpkgs.hostPlatform = platform;
  system.stateVersion = stateVersion;

  # Enable Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    # What else do you have a computer for than the internet
    zenBrowserPackage

    # Manager of Nix configs
    git

    # GNOME goodies
    gnome-software
    gnome-calculator
    gnome-calendar
    gnome-screenshot
    
    # Sandboxed package installer
    flatpak

    # file explorer and previewer
    nautilus
    sushi

    # XDG standards and 
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    
    # Printer configuration
    system-config-printer
  ];

  services.flatpak.enable = true;

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 30d";
  };
  
  # Auto update flake and flatpak
  systemd.timers."auto-update-config" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Tue..Sun";
      Persistent = true;
      Unit = "auto-update-config.service";
    };
  };

  systemd.services."auto-update-config" = {
    script = ''
      set -eu

      ${updateZenixbookGitScript}

      ${updateSystemFlatpaksScript}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
  };

  # Auto Upgrade NixOS
  systemd.timers."auto-upgrade" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon";
      Persistent = true;
      Unit = "auto-upgrade.service";
    };
  };

  systemd.services."auto-upgrade" = {
    script = ''
      set -eu

      ${updateZenixbookGitScript}

      ${notifyUsersScript} "Starting System Updates" "System updates are installing in the background.  You can continue to use your computer while these are running."
            
      ${updateNixosConfigScript}

      # Fix for zoom flatpak
      ${pkgs.flatpak}/bin/flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom

      ${notifyUsersScript} "System Updates Complete" "Updates are complete!  Simply reboot the computer whenever is convenient to apply updates."
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
  };
  
}

# Notes
#
# To reverse zoom flatpak fix:
#   flatpak override --unset-env=ZYPAK_ZYGOTE_STRATEGY_SPAWN us.zoom.Zoom
