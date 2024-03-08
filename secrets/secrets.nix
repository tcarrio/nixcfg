let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) systems;
  inherit (systems) glass;

  autoMeshSystems = [
    glass.tcarrio
    glass.host
  ];
in
{
  "users/tcarrio/ssh.age".publicKeys = [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = autoMeshSystems;
  "services/tailscale/token.age".publicKeys = autoMeshSystems;
}
