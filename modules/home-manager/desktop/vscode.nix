{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.desktop.vscode;

  userSettings = {
    "workbench.iconTheme" = "vscode-icons";
    "[jsonc]" = {
      "editor.quickSuggestions" = {
        "strings" = true;
      };
      "editor.suggest.insertMode" = "replace";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "vscode.typescript-language-features";
    };
    "[json]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "editor.fontLigatures" = true;
    "editor.fontSize" = 12;
    "editor.fontFamily" =
      "'Ubuntu Mono derivative Powerline', 'CaskaydiaMono Nerd Font Propo', 'Droid Sans Mono', 'monospace', monospace";
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.fontFamily" =
      "'Ubuntu Mono derivative Powerline', 'CaskaydiaMono Nerd Font Propo', 'Droid Sans Mono', 'monospace', monospace";
    "workbench.colorTheme" = cfg.colorTheme;
  };
in
{
  options.oxc.desktop.vscode = {
    enable = lib.mkEnableOption "VS Code user settings management (works for any VS Code install, incl. deb)";

    colorTheme = lib.mkOption {
      type = lib.types.str;
      default = "Terafox";
      description = "Value of workbench.colorTheme in the default settings preset (the theme label as VS Code lists it)";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = userSettings;
      defaultText = lib.literalExpression "oxc user settings preset";
      description = "User settings written to Code/User/settings.json";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}/Code/User/settings.json".text = builtins.toJSON cfg.settings;
  };
}
