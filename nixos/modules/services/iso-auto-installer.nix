{ lib, config, pkgs, ... }: {
  isoImage.isoName = lib.mkForce "0xc-auto-installer-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  # for the record, the ascii text art is ANSI Shadow
  # https://patorjk.com/software/taag/#p=display&f=ANSI+Shadow
  services.getty.helpLine = ''
     ██████╗ ██╗  ██╗ ██████╗    ██╗███╗   ██╗██╗██╗  ██╗ ██████╗███████╗ ██████╗ 
    ██╔═████╗╚██╗██╔╝██╔════╝   ██╔╝████╗  ██║██║╚██╗██╔╝██╔════╝██╔════╝██╔════╝ 
    ██║██╔██║ ╚███╔╝ ██║       ██╔╝ ██╔██╗ ██║██║ ╚███╔╝ ██║     █████╗  ██║  ███╗
    ████╔╝██║ ██╔██╗ ██║      ██╔╝  ██║╚██╗██║██║ ██╔██╗ ██║     ██╔══╝  ██║   ██║
    ╚██████╔╝██╔╝ ██╗╚██████╗██╔╝   ██║ ╚████║██║██╔╝ ██╗╚██████╗██║     ╚██████╔╝
     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝      ╚═════╝ 

    NixOS Automated Installer Image
  '';
}
