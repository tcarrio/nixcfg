let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) systems;
  inherit (systems) glass obsidian t510;

  autoMeshSystems = [
    glass.host
    systems.nix-proxy-droplet.host
  ];

  admins = [ glass.tcarrio obsidian.tcarrio t510.tcarrio ];
in
{
  "users/tcarrio/ssh.age".publicKeys = admins ++ [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = admins ++ autoMeshSystems;
  "services/tailscale/token.age".publicKeys = admins ++ autoMeshSystems;
  # "services/jira-cli/token.age".publicKeys = macos;
  "services/acme/cloudflare.age".publicKeys = admins ++ [ systems.nix-proxy-droplet.host ];
  "services/hoarder/env.age".publicKeys = admins ++ [ systems.obsidian.host ];

  "network-shares/ds418/smb.conf.age".publicKeys = admins;

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc1/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc2/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc3/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc4/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc5/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc6/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc7/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc8/ssh_host_ed25519_key.age".publicKeys = admins;
  "hosts/nuc9/ssh_host_ed25519_key.age".publicKeys = admins;
}
