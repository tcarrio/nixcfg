{ config, ... }:
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
