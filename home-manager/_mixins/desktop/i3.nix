{ pkgs, ... }: with pkgs.unstable; {
  
  # home.file = {
  #   ".config/i3/config".text = builtins.readFile ./i3.config;
  # };

  xsession.windowManager.i3.config = let
    modifier = "$mod";
    largeShift = "12";
    smallShift = "3";
    ws1 = "1";
    ws2 = "2";
    ws3 = "3";
    ws4 = "4";
    ws5 = "5";
    ws6 = "6";
    ws7 = "7";
    ws8 = "8";
    ws9 = "9";
    ws10 = "10";
  in {
    modifier = "Mod4";

    menu = "rofi -modi drun,run -show drun";

    keybinds = {
      # shortcuts
      "${modifier}+Return" = "exec ${pkgs.tilix}/bin/tilix";
      "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

      # i3 management
      "${modifier}+Shift+q" = "kill";
      "${modifier}+Shift+c" = "reload";
      "${modifier}+Shift+r" = "restart";
      "${modifier}+Shift+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"";
      
      # audio shortcuts
      "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
      "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
      "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
      "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";

      # window management
      "${modifier}+h" = "focus left";
      "${modifier}+j" = "focus down";
      "${modifier}+k" = "focus up";
      "${modifier}+l" = "focus right";
      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";
      "${modifier}+Shift+h" = "move left";
      "${modifier}+Shift+j" = "move down";
      "${modifier}+Shift+k" = "move up";
      "${modifier}+Shift+l" = "move right";
      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";
      "${modifier}+Shift+h" = "split h";
      "${modifier}+Shift+v" = "split v";
      "${modifier}+f" = "fullscreen toggle";
      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";
      "${modifier}+Shift+space" = "floating toggle";
      "${modifier}+space" = "focus mode_toggle";
      "${modifier}+a" = "focus parent";

      # workspaces
      "${modifier}+1" = "workspace number ${ws1}";
      "${modifier}+2" = "workspace number ${ws2}";
      "${modifier}+3" = "workspace number ${ws3}";
      "${modifier}+4" = "workspace number ${ws4}";
      "${modifier}+5" = "workspace number ${ws5}";
      "${modifier}+6" = "workspace number ${ws6}";
      "${modifier}+7" = "workspace number ${ws7}";
      "${modifier}+8" = "workspace number ${ws8}";
      "${modifier}+9" = "workspace number ${ws9}";
      "${modifier}+0" = "workspace number ${ws10}";
      "${modifier}+Shift+1" = "move container to workspace number ${ws1}";
      "${modifier}+Shift+2" = "move container to workspace number ${ws2}";
      "${modifier}+Shift+3" = "move container to workspace number ${ws3}";
      "${modifier}+Shift+4" = "move container to workspace number ${ws4}";
      "${modifier}+Shift+5" = "move container to workspace number ${ws5}";
      "${modifier}+Shift+6" = "move container to workspace number ${ws6}";
      "${modifier}+Shift+7" = "move container to workspace number ${ws7}";
      "${modifier}+Shift+8" = "move container to workspace number ${ws8}";
      "${modifier}+Shift+9" = "move container to workspace number ${ws9}";
      "${modifier}+Shift+0" = "move container to workspace number ${ws10}";
      
      "${modifier}+r" = "mode \"resize\"";

      modes = {
        resize = {
          "h" = "resize shrink width ${largeShift} px or ${largeShift} ppt";
          "j" = "resize grow height ${largeShift} px or ${largeShift} ppt";
          "k" = "resize shrink height ${largeShift} px or ${largeShift} ppt";
          "l" = "resize grow width ${largeShift} px or ${largeShift} ppt";
          "Left" = "resize shrink width ${smallShift} px or ${smallShift} ppt";
          "Down" = "resize grow height ${smallShift} px or ${smallShift} ppt";
          "Up" = "resize shrink height ${smallShift} px or ${smallShift} ppt";
          "Right" = "resize grow width ${smallShift} px or ${smallShift} ppt";
          "Return" = "mode \"default\"";
          "Escape" = "mode \"default\"";
          "$mod+r" = "mode \"default\"";
        };
      };

      bar = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status}/bin/i3status";
        }
      ];
    };
  };

  # xsession.windowManager.i3.config.fonts = [
  #   "Source Serif"
  #   "Work Sans"
  #   "Fira Sans"
  #   "FiraGO"
  #   "FiraCode Nerd Font Mono"
  #   "SauceCodePro Nerd Font Mono"
  #   "Joypixels"
  #   "Noto Color Emoji"
  # ];

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
  #   package = pkgs.unstable.i3status-rust;
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