# Verifies the web-wrappers module renders one desktop entry file per app.
#
# Regression guard: a `config = { ... } // (lib.mkIf ...)` merge once turned the
# whole module config into an mkIf node, so `xdg.desktopEntries` evaluated to
# `{ }` and no .desktop files were produced. Evaluation still succeeded, so
# only an assertion on the generated files catches it.
{
  inputs,
  pkgs,
  system,
}:
let
  inherit (pkgs) lib;

  hm = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../modules/home-manager/desktop/web-wrappers.nix
      {
        home = {
          username = "tester";
          homeDirectory = "/home/tester";
          stateVersion = "24.05";
        };

        oxc.desktop.web-wrappers = {
          browser = "/opt/test/browser";
          wmClassPrefix = "msedge";
          firefox.browser = "/opt/test/firefox";
          apps = {
            Plain = {
              url = "https://plain.example";
            };
            Named = {
              name = "Friendly Name";
              url = "https://named.example";
              icon = "web-browser";
            };
            Custom = {
              url = "https://custom.example";
              command = opts: "${opts.browserPath} --profile-directory=Alt --app=\"${opts.url}\"";
              wmClass = "explicit-class";
            };
            # Profile, root path, port and query handling in the derived class.
            Music = {
              url = "https://music.carrio.me";
              profile = "Music";
            };
            Deep = {
              url = "https://deep.example:8443/a/b/?x=1#frag";
            };
            # Firefox driver: own profile dir, class from the app id.
            Fox = {
              driver = "firefox";
              url = "https://fox.example";
            };
          };
        };
      }
    ];
  };

  inherit (hm.config.oxc.desktop.web-wrappers) apps;

  # Fast, readable failure: the option tree must yield one entry per app.
  entryNames = builtins.attrNames hm.config.xdg.desktopEntries;
  expectedNames = builtins.attrNames apps;
in
assert lib.assertMsg (entryNames == expectedNames)
  "web-wrappers: xdg.desktopEntries is [${toString entryNames}], expected [${toString expectedNames}]";
pkgs.runCommand "web-wrappers-test-${system}" { } ''
  apps="${hm.config.home.path}/share/applications"

  check() {
    local file="$apps/$1.desktop" pattern="$2"
    if ! test -f "$file"; then
      echo "FAIL: $file does not exist" >&2
      exit 1
    fi
    if ! grep -qF -- "$pattern" "$file"; then
      echo "FAIL: $file does not contain: $pattern" >&2
      cat "$file" >&2
      exit 1
    fi
  }

  check Plain 'Name=Plain'
  check Plain 'Exec=/opt/test/browser --profile-directory=Default --app="https://plain.example" --kiosk'
  check Plain 'StartupWMClass=msedge-plain.example__-Default'
  check Music 'Exec=/opt/test/browser --profile-directory=Music --app="https://music.carrio.me" --kiosk'
  check Music 'StartupWMClass=msedge-music.carrio.me__-Music'
  check Deep 'StartupWMClass=msedge-deep.example__a_b_-Default'
  check Fox 'Exec=/opt/test/firefox --no-remote --profile /home/tester/.local/share/web-apps/Fox --class Fox --name Fox --new-window "https://fox.example"'
  check Fox 'StartupWMClass=Fox'
  check Custom 'StartupWMClass=explicit-class'
  check Named 'Name=Friendly Name'
  check Named 'Icon=web-browser'
  check Custom 'Exec=/opt/test/browser --profile-directory=Alt --app="https://custom.example"'

  # Entries must also be linked into ~/.local/share/applications (watched live
  # by GNOME Shell) and resolve to the rendered profile entries.
  for id in Plain Named Custom Music Deep Fox; do
    link="${hm.config.home-files}/.local/share/applications/$id.desktop"
    if ! test -L "$link" || ! test -f "$link"; then
      echo "FAIL: $link is not a resolving symlink" >&2
      exit 1
    fi
    if ! cmp -s "$link" "$apps/$id.desktop"; then
      echo "FAIL: $link differs from $apps/$id.desktop" >&2
      exit 1
    fi
  done

  # The Firefox driver renders a profile that hides the browser chrome.
  data="${hm.config.home-files}/.local/share/web-apps/Fox"
  grep -qF 'legacyUserProfileCustomizations.stylesheets", true' "$data/user.js" \
    || { echo "FAIL: Fox user.js missing stylesheet pref" >&2; exit 1; }
  grep -qF '#TabsToolbar' "$data/chrome/userChrome.css" \
    || { echo "FAIL: Fox userChrome.css missing" >&2; exit 1; }
  if test -e "${hm.config.home-files}/.local/share/web-apps/Plain"; then
    echo "FAIL: chromium app got a Firefox profile" >&2
    exit 1
  fi

  touch $out
''
