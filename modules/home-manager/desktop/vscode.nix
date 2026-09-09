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
    "workbench.colorTheme" = "Terafox";
  };
in
{
  options.oxc.desktop.vscode = {
    enable = lib.mkEnableOption "VS Code user settings management (works for any VS Code install, incl. deb)";

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
