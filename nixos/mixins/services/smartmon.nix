{
  lib,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      nvme-cli
      smartmontools
    ]
    ++ lib.optionals (config.oxc.host.desktop != null) [
      gsmartcontrol
    ];

  services.smartd.enable = true;
}
