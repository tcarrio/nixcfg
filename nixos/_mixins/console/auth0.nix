{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (pkgs.callPackage ../../../pkgs/auth0.nix { })
    ];
}