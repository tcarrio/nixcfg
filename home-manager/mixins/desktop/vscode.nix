{ config, ... }:
let
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
    "editor.fontFamily" = "'Ubuntu Mono derivative Powerline', 'CaskaydiaMono Nerd Font Propo', 'Droid Sans Mono', 'monospace', monospace";
    "terminal.integrated.fontSize" = 12;
    "terminal.integrated.fontFamily" = "'Ubuntu Mono derivative Powerline', 'CaskaydiaMono Nerd Font Propo', 'Droid Sans Mono', 'monospace', monospace";
    "workbench.colorTheme" = "Terafox";
  };
in
{
  home = {
    file = {
      "${config.xdg.configHome}/Code/User/settings.json".text = builtins.toJSON userSettings;
    };
  };
}
