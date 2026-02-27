# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs, crossDockerPkgs, mkStandardBun, nixvim, uv2nixLib }:
let
  build-oci-image = crossDockerPkgs.callPackage ./build-oci-image.nix { };
in {
  awsesh = pkgs.callPackage ./awsesh.nix { inherit pkgs; };
  gh-composer-auth = pkgs.callPackage ./gh-composer-auth.nix { };
  kube-rsync = pkgs.callPackage ./kube-rsync/default.nix { inherit pkgs; };
  # TODO: Fix non-Darwin build issue
  # mac-launcher = pkgs.callPackage ./mac-launcher.nix { inherit pkgs; };
  zeit = pkgs.callPackage ./zeit.nix { };
  gqurl = pkgs.callPackage ./gqurl/default.nix {
    inherit mkStandardBun;
  };
  nixvim = pkgs.unstable.callPackage ./nixvim/default.nix {
    inherit nixvim;
    pkgs = pkgs.unstable;
  };
  serena = import ./serena/default.nix {
    inherit (pkgs) lib;
    inherit pkgs uv2nixLib;
  };
  sri-hash-gh-repo = import ./sri-hash-gh-repo.nix {
    inherit pkgs;
  };
  tailscale-nix-oci-image = crossDockerPkgs.callPackage ./tailscale-nix-oci-image {
    inherit build-oci-image;
  };
}
