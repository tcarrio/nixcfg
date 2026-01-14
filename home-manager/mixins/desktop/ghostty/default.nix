{ config, inputs, ... }: {
  home = {
    file = {
      "${config.xdg.configHome}/ghostty/config".text = builtins.readFile ./ghostty.conf;
      "${config.xdg.configHome}/ghostty/themes".source = "${inputs.ghostty-catppuccin}/themes";
    };
  };
}
