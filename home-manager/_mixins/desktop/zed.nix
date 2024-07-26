_:
{
  home.file = {
    ".config/zed/settings.json".text = toJSON {
      server_url = "https://disable-zed-downloads.invalid";
      # lsp = {
      #   rust-analyzer = {
      #     binary = {
      #       path = "/run/current-system/sw/bin/rust-analyzer";
      #     };
      #   };
      # };
    };
  };
}
