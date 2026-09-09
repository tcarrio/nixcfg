{ lib, ... }:
{
  imports = [
    ./console
    ./desktop
    ./hardware
    ./services
    ./virt
    ../shared
  ];
}
