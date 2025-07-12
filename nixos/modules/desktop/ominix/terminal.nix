# see install/3-terminal.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      wget
      curl
      unzip
      inetutils
      impala
      fd
      eza
      fzf
      ripgrep
      zoxide
      bat
      wl-clipboard
      fastfetch
      btop
      man
      tldr
      less
      whois
      plocate
      bash-completion
      alacritty
    ];
  };
}