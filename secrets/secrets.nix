let
  sshMatrix = import "../lib/ssh-matrix.nix" { };
  inherit (sshMatrix) systems;
  inherit (systems) glass;
in
{
  "users/tcarrio/ssh.age".publicKeys = [ glass.tcarrio glass.host ];
  "services/tailscale/token.age".publicKeys = [ glass.tcarrio glass.host ];
}
