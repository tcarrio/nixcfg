let
  sshMatrix = import "../lib/ssh-matrix.nix" {};
  systems = sshMatrix.systems;
in
{
  "users/tcarrio/ssh.age".publicKeys = with systems.glass; [ tcarrio host ];
  "services/tailscale/token.age".publicKeys = with systems.glass; [ tcarrio host ];
}