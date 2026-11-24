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

  firefoxPath =
    if lib.isString cfg.firefox.browser then cfg.firefox.browser else lib.getExe cfg.firefox.browser;

  # Firefox launch template. Firefox has no --app mode: a dedicated profile
  # directory plus --no-remote keeps each wrapper a separate instance, and
  # --class/--name give it its own window class. The chrome (tabs, toolbars,
  # menus) is stripped by userChrome.css in the profile, see firefoxProfileFiles.
  defaultFirefoxCommand =
    {
      browserPath,
      url,
      profile,
      wmClass,
      ...
    }:
    ''${browserPath} --no-remote --profile ${profile} --class ${wmClass} --name ${wmClass} --new-window "${url}"'';

  firefoxUserJs = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.inTitlebar", 0);
    user_pref("browser.shell.checkDefaultBrowser", false);
    user_pref("browser.startup.page", 0);
    user_pref("browser.sessionstore.resume_from_crash", false);
    user_pref("browser.toolbars.bookmarks.visibility", "never");
    user_pref("browser.aboutwelcome.enabled", false);
  '';

  firefoxUserChrome = ''
    #TabsToolbar,
    #nav-bar,
    #toolbar-menubar,
    #PersonalToolbar,
    #sidebar-header {
      visibility: collapse !important;
    }
  '';

  # A per-app driver overrides the top-level driver.
  driverFor = app: if app.driver != null then app.driver else cfg.driver;

  firefoxApps = lib.filterAttrs (_: app: driverFor app == "firefox") cfg.apps;

  # Chromium apps use a browser profile name; Firefox apps get their own
  # profile directory named after the app id, so the per-app `profile`
  # option does not apply to them.
  profileFor =
    id: app:
    if driverFor app == "firefox" then
      "${config.xdg.dataHome}/web-apps/${id}"
    else if app.profile != null then
      app.profile
    else
      cfg.profile;

  # Window class GNOME matches against StartupWMClass to group the window
  # under its own entry. Chromium assigns, for an `--app=<url>` window:
  #   <prefix>-<host>_<path, "/" -> "_">-<profile>
  # e.g. https://music.carrio.me with profile Music -> msedge-music.carrio.me__-Music
  # The query string and fragment are ignored. Firefox windows take the class
  # given on the command line, which is the app id.
  wmClassFor =
    id: app:
    if app.wmClass != null then
      app.wmClass
    else if driverFor app == "firefox" then
      id
    else
      let
        parts = builtins.match "[a-zA-Z][a-zA-Z0-9+.-]*://([^/?#:]+)(:[0-9]+)?([^?#]*).*" app.url;
        host = builtins.elemAt parts 0;
        rawPath = builtins.elemAt parts 2;
        path = if rawPath == "" then "/" else rawPath;
      in
      "${cfg.wmClassPrefix}-${host}_${lib.replaceStrings [ "/" ] [ "_" ] path}-${profileFor id app}";

  # Per-app template overrides the driver's template.
  commandFor =
    id: app:
    let
      isFirefox = driverFor app == "firefox";
      template =
        if app.command != null then
          app.command
        else if isFirefox then
          cfg.firefox.command
        else
          cfg.command;
    in
    template {
      inherit (app) name url icon;
      browserPath = if isFirefox then firefoxPath else browserPath;
      profile = profileFor id app;
      wmClass = wmClassFor id app;
    };
in
{
  options.oxc.desktop.web-wrappers = {
    driver = lib.mkOption {
      type = lib.types.enum [
        "chromium"
        "firefox"
      ];
      default = "chromium";
      description = ''
        How apps are wrapped by default. "chromium" uses `--app=<url>` with
        `browser`, `wmClassPrefix`, `profile` and `command` (Chrome, Edge,
        Chromium, Brave). "firefox" uses a per-app profile directory, a
        generated userChrome.css that hides tabs and toolbars, and
        `firefox.browser` and `firefox.command`. Each app can override this.
      '';
    };

    firefox = {
      browser = lib.mkOption {
        type = lib.types.either lib.types.str lib.types.package;
        default = pkgs.firefox;
        defaultText = lib.literalExpression "pkgs.firefox";
        description = ''
          Firefox entry point for apps using the "firefox" driver. Either a
          command name or path resolved at launch (e.g. "/usr/bin/firefox")
          or a package resolved with lib.getExe.
        '';
      };

      command = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
        default = defaultFirefoxCommand;
        description = ''
          Command template for the "firefox" driver: a function from
          ({ name, url, icon, browserPath, profile, wmClass }) to the desktop
          entry Exec string. `profile` is the profile directory path.
        '';
      };
    };

    browser = lib.mkOption {
      type = lib.types.either lib.types.str lib.types.package;
      default = pkgs.chromium;
      defaultText = lib.literalExpression "pkgs.chromium";
      description = ''
        Browser entry point shared by every "chromium" driver app wrapper. Either a command
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
        ({ name, url, icon, browserPath, profile, wmClass }) to the desktop entry Exec
        string for "chromium" driver apps. The default assumes a Chromium-based browser and renders
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
            driver = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "chromium"
                  "firefox"
                ]
              );
              default = null;
              description = "Wrapping driver for this app. Defaults to oxc.desktop.web-wrappers.driver.";
            };
            profile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Browser profile directory for this app (chromium driver only;
                Firefox apps get a profile directory named after the app id).
                Defaults to oxc.desktop.web-wrappers.profile.
              '';
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
                attribute set ({ name, url, icon, browserPath, profile, wmClass }).
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
          exec = commandFor id app;
          categories = [
            "Network"
            "WebBrowser"
          ];
          terminal = false;
          settings.StartupWMClass = wmClassFor id app;
        }
        // lib.optionalAttrs (app.icon != null) { inherit (app) icon; }
      ) cfg.apps;

      # Firefox profile per "firefox" driver app: the directory must exist
      # before launch, and userChrome.css makes the window look app-like.
      xdg.dataFile = lib.concatMapAttrs (id: _: {
        "web-apps/${id}/user.js".text = firefoxUserJs;
        "web-apps/${id}/chrome/userChrome.css".text = firefoxUserChrome;
      }) firefoxApps;
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
