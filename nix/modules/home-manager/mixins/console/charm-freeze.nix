{ pkgs, ... }: {
  home.packages = with pkgs; [ charm-freeze ];

  home.file.".config/freeze/custom.json".text = builtins.readFile ./charm-freeze/config.json;

  programs.fish.shellAliases.frz = "${pkgs.charm-freeze}/bin/freeze -c $HOME/.config/freeze/custom.json";
}
