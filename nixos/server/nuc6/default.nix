# Host: Intel Corporation NUC5PPYB
# CPU: Intel Pentium N3700 (4) @ 2.400GHz
# GPU: Intel Atom/Celeron/Pentium Processor x5-E8000/J3xxx/N3xxx
# Memory: 7877MiB

{ ... }:
{
  imports = [
    # base NUC configuration
    ../../mixins/servers/nuc-base.nix
  ];

  systemd.network.networks."10-lan".networkConfig.Address = "192.168.40.206/24";
}
