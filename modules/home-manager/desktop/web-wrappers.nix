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
      profile,
      ...
    }:
    ''${browserPath} --profile-directory=${profile} --app="${url}" --kiosk'';

  # Per-app template overrides the top-level template, which defaults to
  # the Chromium app/kiosk launch.
  profileFor = app: if app.profile != null then app.profile else cfg.profile;

  commandFor =
    app:
    (if app.command != null then app.command else cfg.command) {
      inherit (app) name url icon;
      inherit browserPath;
      profile = profileFor app;
    };

  # Window class Chromium assigns to an `--app=<url>` window, which GNOME
  # matches against StartupWMClass to group the window under its own entry:
  #   <prefix>-<host>_<path, "/" -> "_">-<profile>
  # e.g. https://music.carrio.me with profile Music -> msedge-music.carrio.me__-Music
  # The query string and fragment are ignored.
  wmClassFor =
    app:
    if app.wmClass != null then
      app.wmClass
    else
      let
        parts = builtins.match "[a-zA-Z][a-zA-Z0-9+.-]*://([^/?#:]+)(:[0-9]+)?([^?#]*).*" app.url;
        host = builtins.elemAt parts 0;
        rawPath = builtins.elemAt parts 2;
        path = if rawPath == "" then "/" else rawPath;
      in
      "${cfg.wmClassPrefix}-${host}_${lib.replaceStrings [ "/" ] [ "_" ] path}-${profileFor app}";
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

    profile = lib.mkOption {
      type = lib.types.str;
      default = "Default";
      description = ''
        Browser profile directory used by every app wrapper unless an app
        sets its own. Passed to the command template as `profile` and used
        to derive the window class.
      '';
    };

    wmClassPrefix = lib.mkOption {
      type = lib.types.str;
      default = "chrome";
      example = "msedge";
      description = ''
        Prefix Chromium puts on app window classes: "chrome" for
        Chrome/Chromium, "msedge" for Edge, "brave" for Brave.
      '';
    };

    command = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      default = defaultCommand;
      description = ''
        Command template: a function from the app attribute set
        ({ name, url, icon, browserPath, profile }) to the desktop entry Exec
        string. The default assumes a Chromium-based browser and renders
        `<browserPath> --profile-directory=<profile> --app="<url>" --kiosk`.
      '';
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "Friendly application name; what desktop search (e.g. GNOME) matches on. Defaults to attribute set key value when not provided.";
              default = null;
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
            profile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Browser profile directory for this app. Defaults to oxc.desktop.web-wrappers.profile.";
            };
            wmClass = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Window class written as StartupWMClass so GNOME groups the
                app's windows under this entry (e.g. in Super+Tab). Derived
                from url, profile and wmClassPrefix when null.
              '';
            };
            command = lib.mkOption {
              type = lib.types.nullOr (lib.types.functionTo lib.types.str);
              default = null;
              description = ''
                Per-app command template overriding
                oxc.desktop.web-wrappers.command. Receives the same
                attribute set ({ name, url, icon, browserPath, profile }).
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

  config = lib.mkMerge [
    {
      xdg.enable = true;

      xdg.desktopEntries = lib.mapAttrs (
        id: app:
        {
          name = if app.name != null then app.name else id;
          exec = commandFor app;
          categories = [
            "Network"
            "WebBrowser"
          ];
          terminal = false;
          settings.StartupWMClass = wmClassFor app;
        }
        // lib.optionalAttrs (app.icon != null) { inherit (app) icon; }
      ) cfg.apps;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      xdg.mime.enable = true;

      # xdg.desktopEntries installs into the profile (home.path), whose store
      # path changes every generation. GNOME Shell watches the old path and
      # misses new entries until re-login. Link each entry into
      # ~/.local/share/applications, a stable directory that is watched live.
      xdg.dataFile = lib.mapAttrs' (
        id: _:
        lib.nameValuePair "applications/${id}.desktop" {
          source = "${config.home.path}/share/applications/${id}.desktop";
        }
      ) cfg.apps;
    })
  ];
}
