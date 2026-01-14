{ pkgs, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.system == "linux";
in
{
  programs.zed-editor = {
    enable = true;

    # Enable Zed on Linux only. Zed will be installed manually on Darwin systems.
    package = if isLinux then pkgs.zed else pkgs.emptyDirectory;

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
    extensions = [ ];

    # {
    #   "buffer_font_family": "Ubuntu Mono derivative Powerline",
    #   "ui_font_family": "Ubuntu",
    #   "minimap": {
    #     "show": "always"
    #   },
    #   "inlay_hints": {
    #     "enabled": true,
    #     "show_value_hints": true,
    #     "show_type_hints": true,
    #     "show_parameter_hints": true,
    #     "show_other_hints": true,
    #     "show_background": false,
    #     "edit_debounce_ms": 700,
    #     "scroll_debounce_ms": 50,
    #     "toggle_on_modifiers_press": {
    #       "control": false,
    #       "alt": false,
    #       "shift": false,
    #       "platform": false,
    #       "function": false
    #     }
    #   },
    #   "telemetry": {
    #     "diagnostics": true,
    #     "metrics": true
    #   },
    #   "ui_font_size": 14.0,
    #   "buffer_font_size": 14,
    #   "theme": {
    #     "mode": "system",
    #     "light": "One Light",
    #     "dark": "Terafox - opaque"
    #   },
    #   "terminal": {
    #     "shell": {
    #       "program": "/Users/tcarrio/.nix-profile/bin/fish"
    #     },
    #     "font_size": 14
    #   }
    # }
    userSettings = {
      assistant = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;
        ### PROVIDER OPTIONS
        ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
        ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
        ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };

        # inline_alternatives = [
        #   {
        #     provider = "copilot_chat";
        #     model = "gpt-3.5-turbo";
        #   }
        # ];
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
            directories = [ ".venv" "venv" ];
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
          language_servers = [ "!lexical" "elixir-ls" "!next-ls" ];
          format_on_save = {
            external = {
              command = "mix";
              arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ];
            };
          };
        };
        "HEEX" = {
          language_servers = [ "!lexical" "elixir-ls" "!next-ls" ];
          format_on_save = {
            external = {
              command = "mix";
              arguments = [ "format" "--stdin-filename" "{buffer_path}" "-" ];
            };
          };
        };
      };

      vim_mode = false;

      ## tell zed to use direnv and direnv can use a flake.nix enviroment.
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Terafox - opaque";
      };
      show_whitespaces = "all";

      ui_font_family = "Ubuntu";
      ui_font_size = 14;

      buffer_font_family = "Ubuntu Mono derivative Powerline";
      buffer_font_size = 14;
    };
  };
}
