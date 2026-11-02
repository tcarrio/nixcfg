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
          command = opts: "${opts.browserPath} --profile-directory=Default --app=\"${opts.url}\"";
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
  check Plain 'Exec=/opt/test/browser --profile-directory=Default --app="https://plain.example"'
  check Named 'Name=Friendly Name'
  check Named 'Icon=web-browser'
  check Custom 'Exec=/opt/test/browser --profile-directory=Alt --app="https://custom.example"'

  touch $out
''
