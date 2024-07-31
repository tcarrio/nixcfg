{ lib, desktop, ... }: {
  imports = [
    ./hardware
    ./services
  ] ++ lib.optionals (desktop != null) [ ./desktop ];
}
