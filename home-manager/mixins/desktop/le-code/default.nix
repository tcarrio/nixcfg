{ pkgs, ... }:
let
  iconFile = ./lechat.png;
  desktopFile = pkgs.writeTextFile {
    name = "le-code.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Le Code
      Comment=Launch Le Chat directly to Code Sessions
      Icon=${iconFile}
      Exec=${pkgs.google-chrome}/bin/google-chrome-stable --app="https://chat.mistral.ai/code_session" %U
      Terminal=false
    '';
  };
in
{
  home.file.".local/share/applications/le-code.desktop".source = desktopFile;
}
