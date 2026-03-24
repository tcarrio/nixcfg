{ lib, desktop, ... }:
{
  imports = [
    ./console
    ./hardware
    ./services
    ./virt
    ../shared
  ]
  ++ lib.optionals (desktop != null) [ ./desktop ];
}
