{ lib, pkgs, desktop, ... }:
{
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;


  console.keyMap = lib.mkForce "us";

  environment.systemPackages = with pkgs; [
    # cpu / IO
    stress
    stress-ng
    stressapptest

    # memory
    memtester

    # disk recovery tools
    testdisk
    ddrescue
    safecopy
    parted
    fsarchiver
    partclone

    # encryption tools
    cryptsetup
    gnupg
    age

    # filesystem maintenance
    gptfdisk

    # filesystem support
    ntfs3g
    e2fsprogs
    xfsprogs
    btrfs-progs

    # specific filesystem recovery tools
    ext4magic
    xfs-undelete
    fatcat

    # boot loader access
    grub2
    efibootmgr

    # network backup
    rsync
    rclone

    # network tools
    networkmanager
    iproute2
    tcpdump
    netcat-gnu

    # private networking
    openvpn3
    wireguard-tools
    tailscale

    # miscellaneous tools
    util-linux
    sleuthkit
    coreutils-full

    # internet access
    firefox

    # windows tooling
    rdesktop
    chntpw
    samba4Full

    # file editors
    neovim

    # file archive & compression tools
    gnutar
    gzip
    xz
    zstd
    lz4
    bzip2
    zip
    p7zip

    # ISO utils
    cdrtools

    # Hex editors
    hexedit
  ];

  services.getty.helpLine = ''
    ██╗███████╗ ██████╗       ██████╗ ███████╗ ██████╗ ██████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗
    ██║██╔════╝██╔═══██╗      ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
    ██║███████╗██║   ██║█████╗██████╔╝█████╗  ██║     ██║   ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝
    ██║╚════██║██║   ██║╚════╝██╔══██╗██╔══╝  ██║     ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝
    ██║███████║╚██████╔╝      ██║  ██║███████╗╚██████╗╚██████╔╝ ╚████╔╝ ███████╗██║  ██║   ██║
    ╚═╝╚══════╝ ╚═════╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝

    NixOS Recovery Image
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.swraid.enable = true;
}
