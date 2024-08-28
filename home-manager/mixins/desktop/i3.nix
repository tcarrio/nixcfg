{ pkgs, ... }: with pkgs; {

  home.file = {
    ".config/i3/config".text = builtins.readFile ./i3.config;
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
