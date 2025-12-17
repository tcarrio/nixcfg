{ ... }: {
  imports = [
    ./aqua.nix
    ./docker.nix
    ./nix-applications.nix
    ./podman.nix
    ./sol.nix
    ./spotlight.nix
    ./yubikey.nix
  ];
}
