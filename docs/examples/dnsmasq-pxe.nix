{ pkgs, ... }: {
  options.oxc.services.pxemasq = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable a PXE boot service powered by dnsmasq in ProxyDHCP mode";
    };

    tftpRootDirectory = lib.mkOption {
      type = lib.types.string;
      default = "/var/tftp-root";
      description = "The root directory to serve content via TFTP";
    };

    dhcpSubnet = lib.mkOption {
      type = lib.types.string;
      default = "127.0.0.1/32";
      description = "The DHCP server to proxy addresses from";
    };

    # TODO: Log configuration

    bootConfigurations = lib.mkOption{
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Mapping of MAC addresses to NixOS configurations";
    };
  };

  config = lib.mkIf config.oxc.services.pxemasq.enable (
    let
      cfg = config.oxc.services.pxemasq;
    in
    {
      # Whether to enable DNSmasq
      services.dnsmasq.enable = true;

      # This option specifies port on which DNSmasq will listen
      services.dnsmasq.port = 0; # Disables DNS server functionality

      # Whether dnsmasq should resolve local queries (i.e. add 127.0.0.1 to /etc/resolv.conf)
      services.dnsmasq.resolveLocalQueries = false;

      # Configuration of dnsmasq
      services.dnsmasq.settings = ''
        # Log lots of extra information about DHCP transactions.
        log-dhcp

        # Disable DHCP
        dhcp-range=${cfg.dhcpSubnet},proxy

        # Set the root directory for files available via FTP.
        enable-tftp
        tftp-root=${cfg.tftpRootDirectory}

        # The boot filename, Server name, Server Ip Address
        dhcp-boot=undionly.kpxe,,<fog_server_IP>

        # Disable re-use of the DHCP servername and filename fields as extra
        # option space. That's to avoid confusing some old or broken DHCP clients.
        dhcp-no-override

        # inspect the vendor class string and match the text to set the tag
        dhcp-vendorclass=BIOS,PXEClient:Arch:00000
        dhcp-vendorclass=UEFI32,PXEClient:Arch:00006
        dhcp-vendorclass=UEFI,PXEClient:Arch:00007
        dhcp-vendorclass=UEFI64,PXEClient:Arch:00009

        # Set the boot file name based on the matching tag from the vendor class (above)
        dhcp-boot=net:UEFI32,i386-efi/ipxe.efi,,<fog_server_IP>
        dhcp-boot=net:UEFI,ipxe.efi,,<fog_server_IP>
        dhcp-boot=net:UEFI64,ipxe.efi,,<fog_server_IP>

        # PXE menu
        # The 1st part is the text displayed to the user.
        # The 2nd part is the timeout, in seconds.
        pxe-prompt="Booting PXE Client", 2

        # # The known types are x86PC, PC98, IA64_EFI, Alpha, Arc_x86,
        # # Intel_Lean_Client, IA32_EFI, BC_EFI, Xscale_EFI and X86-64_EFI
        # # This option is first and will be the default if there is no input from the user.
        # pxe-service=X86PC, "Boot to BIOS", undionly.kpxe
        # pxe-service=X86-64_EFI, "Boot to UEFI", ipxe.efi
        # pxe-service=BC_EFI, "Boot to UEFI PXE-BC", ipxe.efi

        # dhcp-match=set:efi-x86_64,option:client-arch,7
        # dhcp-boot=tag:efi-x86_64,efi64/syslinux.efi
      '';

      config.system.activationScripts.pxemasqDataCopy = lib.stringAfter [ "var" ] ''
        mkdir -p ${cfg.tftpRootDirectory}

        mkdir -p ${cfg.tftpRootDirectory}/efi/amd64

        cp ${pkgs.ipxe}/ipxe.efi ${cfg.tftpRootDirectory}/efi/amd64/ipxe.efi

        mkdir -p ${cfg.tftpRootDirectory}/sys/amd64

        # TODO: Map each attribute entry system derivation to path in root
      '';
    }
  );
}
