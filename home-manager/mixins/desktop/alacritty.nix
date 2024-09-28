{ ... }: {
  programs.alacritty.settings = {
    selection.save_to_clipboard = true;
    font.size = 8.0;
    window.padding = {
      x = 8;
      y = 8;
    };
    keyboard.bindings = [
      { key = "N"; mods = "Control|Shift"; action = "CreateNewWindow"; }
    ];
  };
}
