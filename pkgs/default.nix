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
  nixcfgSource ? null,
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
  # Built against pkgs.unstable, not pkgs: orca overlays home-assistant from
  # unstable (hass.nix), and buildHomeAssistantComponent binds the overlaid
  # HA's python harness. Mixing the 26.05 builder wrapper with unstable's
  # buildPythonPackage drops `domain` from the derivation attrs, failing
  # manifestCheckPhase ("Derivation attribute domain (None)"). Unstable's
  # harness is self-consistent and matches the HA version actually deployed.
  robovac = pkgs.unstable.callPackage ./robovac.nix { };
  happy-coder = pkgs.callPackage ./happy-coder/package.nix { };
  sri-hash-gh-repo = pkgs.callPackage ./sri-hash-gh-repo.nix { };
  qq-cli = pkgs.callPackage ./qq-cli.nix { };
  vid2gif = pkgs.callPackage ./vid2gif/default.nix { };
  worktree-cli = pkgs.callPackage ./worktree-cli/default.nix { };
}
// (
  if nixcfgSource != null then
    {
      devshell-for = pkgs.callPackage ./devshell-for.nix { inherit nixcfgSource; };
    }
  else
    { }
)
// (
  if mkStandardBun != null then
    {
      gqurl = pkgs.callPackage ./gqurl/default.nix {
        inherit mkStandardBun;
      };
    }
  else
    { }
)
// (
  if nixvim != null then
    {
      nixvim = pkgs.unstable.callPackage ./nixvim/default.nix {
        inherit nixvim;
      };
    }
  else
    { }
)
// (
  if uv2nixLib != null then
    {
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
    }
  else
    { }
)
