# see install/printer.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      cups-filters
      system-config-printer
    ];

    services.printing.enable = true;
    services.printing.cups-pdf.enable = true;

    # TODO: Make configurable. Initial default value.
    services.printing.drivers = with pkgs; [
      gutenprint hplip splix
    ];
  };
}
