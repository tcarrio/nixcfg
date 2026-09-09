# greybox uses a different account name but shares the full tcarrio user
# mixin (git identity, fish, devshell aliases, per-host/per-system lookups).
# The hosts/ and systems/ path-existence lookups inside that mixin resolve
# relative to users/tcarrio, so hosts/greybox.nix is picked up from there.
{
  ...
}:
{
  imports = [ ../tcarrio/default.nix ];
}
