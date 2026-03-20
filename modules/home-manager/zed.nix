{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.zed-editor;
in
{
  options.oxc.zed-editor = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zed editor";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.zed-editor;
      description = "The package to utilize for the Zed editor";
    };

    ## See https://github.com/zed-industries/zed/tree/main/extensions
    ## and https://github.com/zed-extensions
    ## At the time of writing, this includes:
    ## zed/extensions:
    ## - csharp
    ## - deno
    ## - elixir
    ## - emmet
    ## - erlang
    ## - glsl
    ## - haskell
    ## - html
    ## - lua
    ## - perplexity
    ## - php
    ## - prisma
    ## - proto
    ## - purescript
    ## - ruff
    ## - scheme
    ## - slash-commands-example
    ## - snippets
    ## - terraform
    ## - test-extension
    ## - toml
    ## - uiua
    ## - zig
    ## zed-extensions:
    ## - astro
    ## - beancount
    ## - clojure
    ## - dart
    ## - elm
    ## - java
    ## - kotlin
    ## - log
    ## - nix
    ## - nu
    ## - ocaml
    ## - postgres-context-server
    ## - racket
    ## - ruby
    ## - sql
    ## - svelte
    ## - swift
    ## - vue
    ## - zed-roc
    extensions = lib.mkOption {
      default = [ ];
      description = "The extensions to enable for the Zed editor by default";
      type = lib.types.listOf (
        lib.types.enum [
          "astro"
          "beancount"
          "clojure"
          "csharp"
          "dart"
          "deno"
          "elixir"
          "elm"
          "emmet"
          "erlang"
          "glsl"
          "haskell"
          "html"
          "java"
          "kotlin"
          "log"
          "lua"
          "nix"
          "nu"
          "ocaml"
          "perplexity"
          "php"
          "postgres-context-server"
          "prisma"
          "proto"
          "purescript"
          "racket"
          "ruby"
          "ruff"
          "scheme"
          "slash-commands-example"
          "snippets"
          "sql"
          "svelte"
          "swift"
          "terraform"
          "test-extension"
          "toml"
          "uiua"
          "vue"
          "zed-roc"
          "zig"
        ]
      );
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      inherit (cfg) enable package extensions;

      userSettings = {
        agent = {
          enabled = false;
          default_open_ai_model = null;
          default_model = null;
        };

        node.path = "${pkgs.nodejs}/bin/node";
        node.npm_path = "${pkgs.nodejs}/bin/npm";

        hour_format = "hour24";
        auto_update = false;
        terminal = {
          alternate_scroll = "off";
          blinking = "off";
          copy_on_select = false;
          dock = "bottom";
          detect_venv = {
            on = {
              directories = [
                ".venv"
                "venv"
              ];
              activate_script = "default";
            };
          };
          env = {
            TERM = "alacritty";
          };
          font_family = "Ubuntu Mono derivative Powerline";
          font_size = 14;
          line_height = "comfortable";

          option_as_meta = false;
          button = false;
          shell.program = "${pkgs.fish}/bin/fish";
          toolbar.title = true;
          working_directory = "current_project_directory";
        };

        minimap = {
          show = "always";
        };
        inlay_hints = {
          enabled = true;
          show_value_hints = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = false;
          edit_debounce_ms = 700;
          scroll_debounce_ms = 50;
          toggle_on_modifiers_press = {
            control = false;
            alt = false;
            shift = false;
            platform = false;
            function = false;
          };
        };

        lsp = {
          rust-analyzer = {
            binary = {
              path_lookup = true;
            };
          };
          nix = {
            binary = {
              path_lookup = true;
            };
          };

          elixir-ls = {
            binary = {
              path_lookup = true;
            };
            settings = {
              dialyzerEnabled = true;
            };
          };
        };

        languages = {
          "Elixir" = {
            language_servers = [
              "!lexical"
              "elixir-ls"
              "!next-ls"
            ];
            formatter = {
              external = {
                command = "mix";
                arguments = [
                  "format"
                  "--stdin-filename"
                  "{buffer_path}"
                  "-"
                ];
              };
            };
            format_on_save = "on";
          };
          "HEEX" = {
            language_servers = [
              "!lexical"
              "elixir-ls"
              "!next-ls"
            ];
            formatter = {
              external = {
                command = "mix";
                arguments = [
                  "format"
                  "--stdin-filename"
                  "{buffer_path}"
                  "-"
                ];
              };
            };
            format_on_save = "on";
          };
        };

        vim_mode = false;

        ## tell zed to use direnv and direnv can use a flake.nix enviroment.
        load_direnv = "shell_hook";
        base_keymap = "VSCode";
        theme = {
          mode = "system";
          light = "One Light";
          dark = "Terafox";
        };
        show_whitespaces = "all";

        ui_font_family = "Ubuntu";
        ui_font_size = 14;

        buffer_font_family = "Ubuntu Mono derivative Powerline";
        buffer_font_size = 14;
      };
    };
  };
}
