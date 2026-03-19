{ pkgs, ... }: {
  # Global packages on host
  environment.systemPackages = with pkgs; [
    openmw
    open-webui
    tor-browser
    heroic
  ];

  # OpenRGB configurations
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };

  # Various desktop apps from core modules
  oxc.desktop = {
    bitwarden.enable = true;
    daw.enable = true;
    fonts.ultraMode = true;
    ente.enable = true;
    logseq.enable = true;
    obs-studio.enable = true;
    signal.enable = true;
    steam = {
      enable = true;
      audioSupport.jack = true;
      audioSupport.pipewire = true;
      steamPlay.enable = true;
      steamPlay.firewall.open = true;
      gamemode = true;
      gamescope = true;
    };
    transmission = {
      enable = true;
      firewall.open = true;
    };
    vscode = {
      enable = true;
      support = {
        bazel = true;
        deno = true;
        diff = true;
        docker = true;
        editorconfig = true;
        elm = true;
        github = true;
        gitlens = true;
        go = true;
        grpc = true;
        hugo = true;
        icons = true;
        js = true;
        linux = true;
        nix = true;
        php = true;
        prisma = true;
        python = true;
        rust = true;
        ssh = true;
        text = true;
        tf = true;
        xml = true;
        yaml = true;
      };
      server.enable = true;
    };
    zed-editor.enable = false;
    zen-browser.enable = true;
  };
}
