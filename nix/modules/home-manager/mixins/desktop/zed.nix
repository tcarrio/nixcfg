{ config, pkgs, lib, ... }:
{
  home.file = {
    "${config.xdg.configHome}/zed/settings.json".text = builtins.toJSON {
      # Zed settings
      #
      # For information on how to configure Zed, see the Zed
      # documentation: https://zed.dev/docs/configuring-zed
      #
      # To see all of Zed's default settings without changing your
      # custom settings, run the `open default settings` command
      # from the command palette or from `Zed` application menu.

      # disable automatic LSP downloads
      server_url = "https://disable-zed-downloads.invalid";

      # disable telemetry
      telemetry.diagnostics = false;
      telemetry.metrics = false;

      # no vim rn
      vim_mode = false;

      # theme it
      theme = "Terafox";

      # ui config
      ui_font_size = 15;
      ui_font_family = "Ubuntu Mono derivative Powerline";

      # buffer config
      buffer_font_family = "Ubuntu Mono derivative Powerline";
      buffer_font_size = 15;

      # terminal config
      terminal.font_size = 15;
      terminal.dock = "bottom";
      terminal.font_family = "Ubuntu Mono derivative Powerline";

      # disable chat
      chat_panel.button = false;

      # language servers configuration
      lsp = { };
    };
  };
}


{
  programs.zed-editor = {
    enable = true;
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
    extensions = [
      "elixir"
      "lua"
      "make"
      "nix"
      "php"
      "terraform"
      "toml"
    ];

    ## everything inside of these brackets are Zed options.
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

        #        inline_alternatives = [
        #          {
        #            provider = "copilot_chat";
        #            model = "gpt-3.5-turbo";
        #          }
        #        ];
      };

      node.path = lib.getExe pkgs.nodejs;
      node.npm_path = lib.getExe pkgs.nodejs "npm";

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
        font_family = "FiraCode Nerd Font";
        font_features = null;
        font_size = null;
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell.program = lib.getExe pkgs.fish;
        toolbar.title = true;
        working_directory = "current_project_directory";
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

      vim_mode = true;
      ## tell zed to use direnv and direnv can use a flake.nix enviroment.
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
      show_whitespaces = "all";
      ui_font_size = 16;
      buffer_font_size = 16;

    };

  };
}
