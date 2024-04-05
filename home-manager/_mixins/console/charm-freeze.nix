{ pkgs, ... }: {
    home.packages = with pkgs; [ charm-freeze ];

    home.file.".config/freeze/user.json".text = builtins.readFile ./charm-freeze/config.json;
}