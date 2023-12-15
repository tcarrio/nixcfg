{ desktop, lib, ... }:
{
  imports =
    [
      ./docker.nix
      # ./podman.nix
    ]
    ++ lib.optional (builtins.isString desktop) ./desktop.nix;
  # TODO: Make containerization tools dynamic
  # ++ lib.optional (builtins.isString containerization) ./${containerization}.nix;
}
