{ lib, ... }: {
    rebuild-host = lib.mkForce "darwin-rebuild switch --flake $HOME/0xc/nix-config";
}
