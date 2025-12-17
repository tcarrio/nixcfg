{ pkgs, ... }:
with pkgs; {
  home.file = {
    ".config/i3/config".text = builtins.readFile ./i3.config;
    ".config/picom/picom.conf".text = builtins.readFile ./picom.conf;
  };

  services.polybar.settings = {
    "settings" = {
      # pseudo-transparency = true;
    };

    "colors" = {
      background = "#331e222a";
      foreground = "#ffffff";
      fg-blue = "#5294e2";
      focus-dark = "#1b2124";
      blue = "#73d0ff";
      blue-darker = "#0771ed";
      green = "#bae67e";
      dark-green = "#75c933";
      red = "#ff3333";
      cyan = "#95e6cb";
      alpha = "#00000000";
      white = "#fff";
      yellow = "#FFEF00";
      coffee = "#805a3f";

      dark-light = "#272A2B";
      active-light = "#313435";
    };

    "bar/Bar1" = {
      tray-position = "center";
      tray-scale = 1;
      tray-offset-x = 0;
      tray-offset-y = 0;
      tray-padding = 2;
      tray-detached = false;
      tray-foreground = "\${colors.foreground}";
      tray-background = "\${colors.background}";
      tray-transparent = true;
      monitor = "\${env:MONITOR}";
      width = "\${env:POLYBAR_WIDTH}";
      # width =  100%
      height = 20;
      padding-left = 1;
      padding-right = 1;
      background = "\${colors.background}";
      foreground = "\${colors.foreground}";
      bottom = false;
      border-top-size = 7;
      border-bottom-size = 7;
      border-top-color = "\${colors.background}";
      border-bottom-color = "\${colors.background}";
      enable-ipc = true;

      line-size = 1;
      wm-restack = "i3";
      # wm-restack = bspwm
      modules-left = "menu sps i3 title mpd mpd_control";
      modules-center = "";
      modules-right = "pulseaudio mic date cpu caffeine backlightsps caps sps num sps scroll mem wlan battery powermenu";

      font-0 = "JetBrainsMono Nerd Font:style=Bold:pixelsize=11;3";
      font-5 = "Iosevka Nerd Font:style=Medium:size=13;2";
      font-1 = "JetBrainsMono Nerd Font:size=10;3";
      font-2 = "Material Design Icons:style=Bold:size=13;3";
      font-3 = "unifont:fontformat=truetype:size=13:antialias=true;";
      font-4 = "FontAwesome5Free:pixelsize=10";
    };

    "module/sps" = {
      type = "custom/text";
      content = " ";
      content-padding = 0;
    };

    "module/title" = {
      type = "internal/xwindow";

      # Available tags:
      #   <label> (default)
      format = "<label>";
      format-prefix = "%{F#61afef}";
      format-prefix-background = "#331e222a";
      format-prefix-foreground = "#ffffff";
      format-prefix-padding = 1;

      # Available tokens:
      #   %title%
      # Default: %title%
      label = " %title%  ";
      label-maxlen = 26;
      label-background = "#331e222a";
      label-foreground = "#ffffff";
      label-padding = 0;

      # Used instead of label when there is no window title
      label-empty = "Desktop";
      label-empty-background = "#331e222a";
      label-empty-foreground = "#e0def4";
      label-empty-padding = 0;
    };

    "module/mpd" = {
      type = "internal/mpd";

      format = "%a %b %d";

      host = "0.0.0.0";
      port = 6600;

      interval = 2;

      format-online = "<label-song>";
      format-online-background = "\${colors.background}";
      format-online-foreground = "\${colors.fg-blue}";
      # format-online-padding = 20;

      label-song = "%{T2}%artist% - %title%%{T-}";
      label-song-maxlen = 45;
      label-song-ellipsis = true;

      label-offline = "MPD is offline";
    };

    "module/mpd_control" = {
      type = "internal/mpd";

      interval = 2;

      format-online = "<icon-prev> <toggle> <icon-next>";
      format-online-background = "\${colors.background}";
      format-online-foreground = "\${colors.blue}";
      # format-online-padding = 2;

      label-offline = "MPD is offline";

      # Only applies if <icon-X> is used
      icon-play = "%{T1}%{T-}";
      icon-pause = "%{T1}%{T-}";
      icon-stop = "%{T1}%{T-}";
      icon-prev = "%{T1}%{T-}";
      icon-next = "%{T1} %{T-}";
    };

    "module/pulseaudio" = {
      type = "internal/pulseaudio";

      format-volume-prefix = " ";
      format-volume-prefix-foreground = "\${colors.primary}";
      format-volume = "<label-volume>";

      label-volume = "%percentage%%";

      label-muted = "muted";
      label-muted-foreground = "\${colors.disabled}";
      click-right = "exec pavucontrol";
    };

    "module/mic" = {
      type = "custom/script";
      interval = 1;
      label = "%output%";
      exec = "~/.config/polybar/scripts/mic-control.sh";
      click-left = "~/.config/polybar/scripts/mic-control.sh toggle";
    };

    "module/num" = {
      type = "custom/script";
      interval = "0.5s";
      exec = "~/.config/polybar/scripts/cns.sh -n";
      format-foreground = "\${colors.blue}";
    };

    "module/caps" = {
      type = "custom/script";
      interval = "0.5s";
      exec = "~/.config/polybar/scripts/cns.sh -c";
      format-foreground = "\${colors.blue}";
    };

    "module/scroll" = {
      type = "custom/script";
      interval = "0.5s";
      exec = "~/.config/polybar/scripts/cns.sh -s";
      format-foreground = "\${colors.blue}";
    };

    "module/date" = {
      type = "internal/date";
      interval = 1;

      date = "%a %d.%m.%Y";
      date-alt = "%a %d.%m.%Y";

      time = "%a %d %b %I:%M";
      time-alt = "%I:%M - %a %d.%m.%Y";

      format = "<label>";
      format-padding = 2;
      format-foreground = "$(colors.fg-blue)";
      label = "%time%";
    };

    "module/mem" = {
      type = "custom/script";
      exec = "free -m | sed -n 's/^Mem:\s\+[0-9]\+\s\+\([0-9]\+\)\s.\+/\1/p'";
      format = "<label>";
      format-prefix = "󰍛 ";
      format-background = "\${colors.background}";
      format-padding = 0;
      label = "%output%M used";
      label-padding = 1;
      format-foreground = "\${colors.cyan}";
      format-margin = 0;
    };

    "module/menu" = {
      type = "custom/text";
      content = "";
      # content-background = #81A1C1
      content-foreground = "#61afef";
      click-left = "~/.config/rofi2/launchers/type-5/launcher.sh";
      # content-underline = "#4C566A";
      content-padding = 1;
    };

    "module/powermenu" = {
      type = "custom/text";
      content = "";
      click-left = "exec ~/.config/i3/scripts/powermenu";
      # content-background = "#81A1C1";
      content-foreground = "\${colors.foreground}";
      content-padding = 1;
      content-margin = 0;
    };

    "module/sysmenu" = {
      type = "custom/text";
      content = "";
      content-foreground = "\${colors.focus-dark}";
      content-padding = 1;
      click-left = "~/.config/polybar/scripts/powermenu.sh";
    };

    "module/backlight" = {
      type = "internal/backlight";
      # Use the following command to list available cards:
      # $ ls -1 /sys/class/backlight/
      card = "intel_backlight";

      format = "<ramp> <label>";
      format-padding = 1;
      format-foreground = "$(color.yellow)";
      enable-scroll = true;

      label = "%percentage%% ";
      ramp-foreground = "$(color.yellow)";
      # Only applies if <ramp> is used
      ramp-0 = "󰃜";
      ramp-1 = "󰃝";
      ramp-2 = "󰃞";
      ramp-3 = "󰃟";
      ramp-4 = "󰃠";
    };

    "module/wlan" = {
      type = "internal/network";
      interface = "wlp2s0";
      interval = "3.0";
      format-connected = "<label-connected>";
      label-connected = "󰤧 %essid% %downspeed% %upspeed%";
      label-connected-foreground = "\${colors.green}";
      label-disconnected = "󰤭 ";
      label-disconnedted-foreground = "\${colors.red}";
      label-connected-background = "\${colors.backgoound}";
      label-disconnected-bacoground = "\${colors.backgoound}";
    };

    "module/battery" = {
      type = "internal/battery";

      full-at = "\${config.battery-full-at}";
      battery = "\${config.battery-bat}";
      adapter = "\${config.battery-adp}";

      format-charging = "<animation-charging> <label-charging>";
      label-charging = "%percentage%%";
      # format-charging-underline = "\${colors.foreground}";
      animation-charging-0 = "  ";
      animation-charging-1 = "  ";
      animation-charging-2 = "  ";
      animation-charging-3 = "  ";
      animation-charging-4 = "  ";
      animation-charging-framerate = 750;

      format-discharging = "<ramp-capacity> <label-discharging>";
      label-discharging = "%percentage%%";

      #format-discharging-underline = "\${colors.notify}";
      ramp-capacity-0 = "  ";
      ramp-capacity-1 = "  ";
      ramp-capacity-2 = "  ";
      ramp-capacity-3 = "  ";
      ramp-capacity-4 = "  ";
      ramp-capacity-foreground = "\${colors.notify}";

      label-full = "  ";
      label-full-foreground = "\${colors.success}";
      label-full-underline = "\${colors.success}";

      label-padding = 2;

      interval = 60;

      exec = "~/.config/polybar/scripts/battery_notify.sh";
    };

    "module/cpu" = {
      type = "internal/cpu";
      interval = 2.5;

      format = "<label>";
      format-padding = 1;
      format-margin = 0;

      label = "%{F#58b019}󰻟 %{F-}%percentage%%";
      # format-backgoound = "\${colors.color12} 
      format-foreground = "\${colors.foreground}";
    };

    "module/xwindow" = {
      type = "internal/xwindow";

      label = "%title%";
      label-maxlen = 20;
      label-foreground = "\${colors.foreground}";
      label-padding = 1;
      # Used instead of label when there is no window title
      label-empty = "";
      # label-empty-foreground = "\${color.blue-light}
      label-empty-padding = 2;
    };

    "module/i3" = {
      type = "internal/i3";

      pin-workspaces = "\${config.i3-pin-workspaces}";

      strip-wsnumbers = true;

      index-sort = true;
      enable-click = true;
      enable-scroll = true;
      wrapping-scroll = true;
      reverse-scroll = true;

      fuzzy-match = false;

      # Available tags:
      #   <label-state> (default) - gets replaced with <label-(focused|unfocused|visible|urgent)>
      #   <label-mode> (default)
      format = "<label-state> <label-mode>";

      # icons
      ws-icon-0 = "\${config.ws-icon-0}";
      ws-icon-1 = "\${config.ws-icon-1}";
      ws-icon-2 = "\${config.ws-icon-2}";
      ws-icon-3 = "\${config.ws-icon-3}";
      ws-icon-4 = "\${config.ws-icon-4}";
      ws-icon-5 = "\${config.ws-icon-5}";
      ws-icon-6 = "\${config.ws-icon-6}";
      ws-icon-7 = "\${config.ws-icon-7}";
      ws-icon-8 = "\${config.ws-icon-8}";
      ws-icon-9 = "\${config.ws-icon-9}";
      ws-icon-default = "\${config.ws-icon-default}";

      label-monitor = "%name%";

      label-dimmed-foreground = "#555";
      label-dimmed-underline = "\${bar/top.background}";
      label-dimmed-focused-background = "#f00";

      label-focused = "  ";
      label-focused-foreground = "\${colors.foreground}";
      label-focused-background = "\${colors.background}";

      label-occupied = "  ";
      label-occupied-padding = 0;
      label-occupied-foreground = "\${colors.fg-blue}";

      label-urgent = "  ";
      label-urgent-foreground = "\${colors.red}";
      label-urgent-padding = 0;

      label-unfocused = "  ";
      label-unfocused-foreground = "\${colors.foreground}";
      label-unfocused-padding = 0;

      label-empty = "";
      label-empty-padding = 0;
      label-empty-foreground = "\${colors.foreground}";
      label-empty-font = 1;

      # Separator in between workspaces
      label-separator = "";
      label-separator-padding = 0;
      label-separator-foreground = "#ffb52a";
    };

    "module/caffeine" = {
      type = "custom/ipc";
      hook-0 = "echo \" 󰾪 \""; #Use a Nerd or FontAwesome icon for the off state
      hook-1 = "echo \"  \""; #Use a Nerd or FontAwesome icon for the on state
      click-left = "/usr/local/bin/caffeine";
      initial = 1;
      format = "<label>";
      format-foreground = "\${color.coffee}";
      format-background = "\${color.background}";
    };
  };

  # xsession.windowManager.i3 = {
  #   config = {
  #     bars = [
  #       {
  #         position = "bottom";
  #         statusCommand = "${i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
  #       }
  #     ];
  #   };
  # };

  # programs.i3status-rust = {
  #   enable = true;
  #   package = pkgs.i3status-rust;
  #   bars = {
  #     top = {
  #       blocks = [
  #        {
  #          block = "time";
  #          interval = 60;
  #          format = "%a %d/%m %k:%M %p";
  #        }
  #      ];
  #     };
  #   };
  # };
}
