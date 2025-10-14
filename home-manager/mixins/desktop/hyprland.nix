{ pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, ${pkgs.rofi}/bin/rofi"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList
            (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
    };

    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    ];

    systemd.variables = [ "--all" ];
  };

  environment.systemPackages = with pkgs; [
    flat-remix-icon-theme
    gnome-themes-extra
    noto-fonts
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  ### TODO: Remove? Redundant to `gtk` configs
  # dconf.settings."org/gnome/desktop/interface" = {
  #   gtk-theme = "Adwaita";
  #   icon-theme = "Flat-Remix-GTK-Grey-Darkest";
  #   document-font-name = "Noto Sans Medium 11";
  #   font-name = "Noto Sans Medium 11";
  #   monospace-font-name = "Noto Sans Mono Medium 11";
  # };
}
