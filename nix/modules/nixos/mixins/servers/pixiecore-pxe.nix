{ self, ... }:
let
  inherit (self.nixosConfigurations.netboot-console.config.system) build;
in
{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true; # Use existing DHCP server.

    mode = "boot";
    kernel = "${build.kernel}/bzImage";
    initrd = "${build.netbootRamdisk}/initrd";
    cmdLine = "init=${build.toplevel}/init loglevel=4";
    debug = true;
  };
}
