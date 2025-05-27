{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    openmw
    open-webui
    tor-browser
    heroic
  ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };

  oxc.desktop = {
    daw.enable = true;
    fonts.ultraMode = true;
    ente.enable = true;
    logseq.enable = true;
    obs-studio.enable = true;
    steam = {
      enable = true;
      audioSupport.jack = true;
      audioSupport.pipewire = true;
      steamPlay.enable = true;
      steamPlay.firewall.open = true;
    };
    transmission = {
      enable = true;
      package = pkgs.transmission_4-qt;
      firewall.open = true;
    };
    vscode = {
      enable = true;
      support = {
        bazel = true;
        elm = true;
        github = true;
        gitlens = true;
        go = true;
        grpc = true;
        linux = true;
        rust = true;
        ssh = true;
      };
      server.enable = true;
    };
    zed-editor.enable = true;
    zen-browser.enable = true;
  };
}
