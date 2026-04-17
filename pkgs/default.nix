# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs,
  nixvim,
  uv2nixLib,
  ...
}:
let

in
{
  awsesh = pkgs.callPackage ./awsesh.nix {};
  gh-composer-auth = pkgs.callPackage ./gh-composer-auth.nix {};
  kube-rsync = pkgs.callPackage ./kube-rsync/default.nix {};
  # TODO: Fix non-Darwin build issue
  # mac-launcher = pkgs.callPackage ./mac-launcher.nix { inherit pkgs; };
  zeit = pkgs.callPackage ./zeit.nix {};
  pug = pkgs.callPackage ./pug.nix {};
  # TODO: Fix gqurl builder
  # gqurl = pkgs.callPackage ./gqurl/default.nix {
  #   inherit mkStandardBun;
  # };
  nixvim = pkgs.unstable.callPackage ./nixvim/default.nix {
    inherit nixvim;
  };
  serena = pkgs.callPackage ./serena/default.nix {
    inherit uv2nixLib;
  };
  endcord = pkgs.callPackage ./endcord {
    inherit pkgs uv2nixLib;
  };
  endcord-media = pkgs.callPackage ./endcord {
    inherit pkgs uv2nixLib;
    withMedia = true;
  };
  sri-hash-gh-repo = pkgs.callPackage ./sri-hash-gh-repo.nix {};
  uri-decode = pkgs.callPackage ./uri-decode.nix {};
  qq-cli = pkgs.callPackage ./qq-cli.nix {};
}
