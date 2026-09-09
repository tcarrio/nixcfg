# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
#
# Input-derived builders are nullable so external consumers can omit them:
# when null, the packages requiring that builder are excluded from the set
# rather than breaking evaluation. Conditions are kept lazy (no strict let
# on pkgs.lib) — this file is imported with pkgs = final inside an overlay.
{
  pkgs,
  nixvim ? null,
  uv2nixLib ? null,
  mkStandardBun ? null,
  ...
}:
{
  awsesh = pkgs.callPackage ./awsesh.nix { };
  bluebox = pkgs.callPackage ./bluebox { };
  gh-composer-auth = pkgs.callPackage ./gh-composer-auth.nix { };
  kube-rsync = pkgs.callPackage ./kube-rsync/default.nix { };
  # TODO: Fix non-Darwin build issue
  # mac-launcher = pkgs.callPackage ./mac-launcher.nix { inherit pkgs; };
  zeit = pkgs.callPackage ./zeit.nix { };
  pug = pkgs.callPackage ./pug.nix { };
  robovac = pkgs.callPackage ./robovac.nix { };
  happy-coder = pkgs.callPackage ./happy-coder/package.nix { };
  sri-hash-gh-repo = pkgs.callPackage ./sri-hash-gh-repo.nix { };
  qq-cli = pkgs.callPackage ./qq-cli.nix { };
}
// (if mkStandardBun != null then {
  gqurl = pkgs.callPackage ./gqurl/default.nix {
    inherit mkStandardBun;
  };
} else { })
// (if nixvim != null then {
  nixvim = pkgs.unstable.callPackage ./nixvim/default.nix {
    inherit nixvim;
  };
} else { })
// (if uv2nixLib != null then {
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
  marker-pdf = pkgs.callPackage ./marker-pdf/default.nix {
    inherit uv2nixLib;
  };
} else { })
