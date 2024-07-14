_:
{
  home.file = {
    ".config/zed/settings.json".text = ''
      {
        "server_url": "https://disable-zed-downloads.invalid"
      }
    '';
  };

  home.packages = with pkgs; [
    zed
  ];
}
