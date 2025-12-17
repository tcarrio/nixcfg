{ pkgs, inputs, ... }: {
  # Global packages on host
  environment.systemPackages = with pkgs; [
    openmw
    open-webui
    tor-browser
    heroic
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.rocket-league
  ];

  # Star Citizen install and requirements
  programs.rsi-launcher.enable = true;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

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
    zed-editor.enable = false;
    zen-browser.enable = true;
  };
}
