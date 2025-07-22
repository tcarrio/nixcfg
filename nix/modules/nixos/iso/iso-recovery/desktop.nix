{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # disk recovery tools
    testdisk-qt
    gparted

    # miscellaneous tools
    autopsy

    # internet access
    firefox

    # windows remote access
    remmina

    # hex editor
    ghex

    # private networking
    trayscale
  ];
}
