{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    logseq
  ];

  # required due to outdated version of Electron used for Logseq
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];
}
