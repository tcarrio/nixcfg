{ pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    browsh # browser in terminal
    ddgr # duckduckgo
    castero # podcasts
    # gomuks # matrix client # BROKEN?
    iamb # matrix client
    impala # network management
    systemctl-tui # systemd
    tdf # pdf viewer
    rainfrog # db client
    wiki-tui # wikipedia
    yazi # file manager
    aerc # email
  ];
}
