{ config, ... }: {
  home.file."${config.xdg.configHome}/discord/settings.json".text = builtins.toJSON {
    SKIP_HOST_UPDATE = true;
  };
}
