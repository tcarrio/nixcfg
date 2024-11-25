let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) systems;
  inherit (systems) glass;

  ageMatrix = import ../lib/age-matrix.nix { };
  inherit (ageMatrix.systems) sktc0;

  autoMeshSystems = [
    glass.tcarrio
    glass.host
    systems.nix-proxy-droplet.host
  ];

  macos = [ sktc0.tcarrio ];
in
{
  "users/tcarrio/ssh.age".publicKeys = [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = autoMeshSystems;
  "services/tailscale/token.age".publicKeys = autoMeshSystems;
  "services/jira-cli/token.age".publicKeys = macos;
  "services/acme/cloudflare.age".publicKeys = with glass; [ tcarrio host systems.nix-proxy-droplet.host ];

  "network-shares/ds418/smb.conf.age".publicKeys = [ glass.tcarrio ];

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
