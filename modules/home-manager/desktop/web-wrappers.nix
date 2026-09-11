{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.web-wrappers;

  # Browser entry point: plain strings pass through verbatim (resolved
  # from PATH at launch), packages resolve to their main program.
  browserPath = if lib.isString cfg.browser then cfg.browser else lib.getExe cfg.browser;

  # Default launch template: Chromium-style app window with kiosk chrome.
  # The --app/--kiosk flags work across Chromium-based browsers (Chrome,
  # Edge, Chromium, Brave, ...).
  defaultCommand =
    {
      browserPath,
      url,
      ...
    }:
    ''${browserPath} --app="${url}" --kiosk'';

  # Per-app template overrides the top-level template, which defaults to
  # the Chromium app/kiosk launch.
  commandFor =
    app:
    (if app.command != null then app.command else cfg.command) {
      inherit (app) name url icon;
      inherit browserPath;
    };
in
{
  options.oxc.desktop.web-wrappers = {
    browser = lib.mkOption {
      type = lib.types.either lib.types.str lib.types.package;
      default = pkgs.chromium;
      defaultText = lib.literalExpression "pkgs.chromium";
      description = ''
        Browser entry point shared by every app wrapper. Either a command
        name resolved from PATH at launch (e.g. "msedge") or a package
        whose main program is resolved with lib.getExe.
      '';
    };

    command = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      default = defaultCommand;
      description = ''
        Command template: a function from the app attribute set
        ({ name, url, icon, browserPath }) to the desktop entry Exec
        string. The default assumes a Chromium-based browser and renders
        `<browserPath> --app="<url>" --kiosk`.
      '';
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Friendly application name; what desktop search (e.g. GNOME) matches on.";
            };
            url = lib.mkOption {
              type = lib.types.str;
              description = "URL the wrapper opens.";
            };
            icon = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
              default = null;
              description = ''
                Optional icon for the desktop entry: an XDG icon theme
                name (e.g. "web-browser") or a file path.
              '';
            };
            command = lib.mkOption {
              type = lib.types.nullOr (lib.types.functionTo lib.types.str);
              default = null;
              description = ''
                Per-app command template overriding
                oxc.desktop.web-wrappers.command. Receives the same
                attribute set ({ name, url, icon, browserPath }).
              '';
            };
          };
        }
      );
      default = { };
      description = ''
        Chromium-based web app wrappers rendered as XDG desktop entries,
        discoverable by friendly name in desktop launchers (e.g. GNOME
        search). The attribute key is the entry's unique id and file name.
      '';
    };
  };

  config = {
    xdg.desktopEntries = lib.mapAttrs (
      _id: app:
      {
        inherit (app) name;
        exec = commandFor app;
        categories = [
          "Network"
          "WebBrowser"
        ];
        terminal = false;
      }
      // lib.optionalAttrs (app.icon != null) { inherit (app) icon; }
    ) cfg.apps;
  };
}
