{ lib, desktop, ... }: {
  imports = [
    ./console
    ./hardware
    ./services
    ./virt
  ] ++ lib.optionals (desktop != null) [ ./desktop ];
}
