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

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc1/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc2/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc3/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc4/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc5/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc6/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc7/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc8/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
  "hosts/nuc9/ssh_host_ed25519_key.age".publicKeys = [ glass.tcarrio ];
}
