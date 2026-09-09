{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.web-app;
in
{
  options.oxc.desktop.web-app = {
    enable = lib.mkEnableOption "generic web-application .desktop launcher";

    name = lib.mkOption {
      type = lib.types.str;
      description = "Application name shown in the desktop entry";
    };

    comment = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Desktop entry comment";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = "URL the launcher opens (chrome app mode)";
    };

    icon = lib.mkOption {
      type = lib.types.path;
      description = "Icon file for the desktop entry";
    };

    browser = lib.mkOption {
      type = lib.types.package;
      default = pkgs.google-chrome;
      defaultText = lib.literalExpression "pkgs.google-chrome";
      description = "Browser used to launch the app window";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".local/share/applications/${cfg.name}.desktop".source = pkgs.writeTextFile {
      name = "${cfg.name}.desktop";
      text = ''
        [Desktop Entry]
        Type=Application
        Name=${cfg.name}
        Comment=${cfg.comment}
        Icon=${cfg.icon}
        Exec=${cfg.browser}/bin/google-chrome-stable --app="${cfg.url}" %U
        Terminal=false
      '';
    };
  };
}
