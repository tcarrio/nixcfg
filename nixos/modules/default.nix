{ lib, desktop, ... }: {
  imports = [
    ./hardware
    ./services
    ./virt
  ] ++ lib.optionals (desktop != null) [ ./desktop ];
}
