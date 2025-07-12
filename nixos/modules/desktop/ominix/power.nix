# see install/power.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    services.power-profiles-daemon.enable = true;

    # Dynamic detection of battery/AC devices and setting the profile
    services.power-profile-setup.enable = true;
    systemd.services.power-profile-setup = {
      description = "Set power profile based on battery presence";
      wantedBy = [ "multi-user.target" ];
      after = [ "power-profiles-daemon.service" ];
      wants = [ "power-profiles-daemon.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "power-profile-setup" ''
          set -e
          
          if ls /sys/class/power_supply/BAT* &>/dev/null; then
            # This computer runs on a battery
            echo "Battery detected - setting balanced power profile"
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced || true
            
            # Enable battery monitoring timer for low battery notifications
            echo "Enabling battery monitor timer"
            systemctl enable --now ominix-battery-monitor.timer || true
          else
            # This computer runs on power outlet
            echo "No battery detected - setting performance power profile"
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || true
          fi
        '';
      };
    };

    systemd.services.ominix-battery-monitor = {
      description = "Ominix Battery Monitor Timer";
      requires = "ominix-battery-monitor.service";

      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "30sec";
        AccuracySec = "10sec";
      };
      
      wantedBy = [ "timers.target" ];
    }
  };
}
