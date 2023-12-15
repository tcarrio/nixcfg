{ pkgs, ... }:
let
  t = pkgs.templateFile;

  values = {
    bin = {
      sketchybar = "${pkgs.sketchybar}";
      yabai = "${pkgs.yabai}";
    };
  };

  sketchybarConfig = t "sketchybarrc" ./sketchybar/sketchybar.conf.mustache values;

  plugins = [
    "battery.sh"
    "clock.sh"
    "cpu.sh"
    "disk.sh"
    "mem.sh"
    "os-ver.sh"
    "package_monitor.sh"
    "space-top.sh"
    "space.sh"
    "toggle_bracket.sh"
    "uptime.sh"
    "window_title.sh"
    "yabai_spaces.sh"
    "yabai.sh"
  ];

  items = [
    "spacenum.sh"
    "spaces.sh"
  ];
in
{
  home.file = {
    ".config/sketchybar/sketchybarrc".source = "${sketchybarConfig}";

    ".config/sketchybar/colors.sh".text = builtins.readFile ./sketchybar/colors.sh;
    ".config/sketchybar/icons.sh".text = builtins.readFile ./sketchybar/icons.sh;
  }

  // # Include plugins
  builtins.listToAttrs (builtins.map
    (plugin: {
      name = ".config/sketchybar/plugins/${plugin}.mustache".source;
      value = t plugin ./sketchybar/plugins/${plugin}.mustache values;
    })
    plugins)

  // # Include items
  builtins.listToAttrs (builtins.map
    (item: {
      name = ".config/sketchybar/items/${item}.mustache".source;
      value = t item ./sketchybar/items/${item}.mustache values;
    })
    items);
}
