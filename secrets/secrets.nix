let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) systems;
  inherit (systems) glass obsidian t510;

  autoMeshSystems = [
    glass.host
    systems.nix-proxy-droplet.host
  ];

  roles = {
    admin = [ glass.tcarrio obsidian.tcarrio t510.tcarrio ];
    deploy = [ ];
  };
in
{
  "users/tcarrio/ssh.age".publicKeys = roles.admin ++ [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = roles.admin ++ autoMeshSystems;
  "services/tailscale/token.age".publicKeys = roles.admin ++ autoMeshSystems;
  # "services/jira-cli/token.age".publicKeys = macos;
  "services/acme/cloudflare.age".publicKeys = roles.admin ++ [ systems.nix-proxy-droplet.host ];
  "services/hoarder/env.age".publicKeys = roles.admin ++ [ systems.obsidian.host ];

  "network-shares/ds418/smb.conf.age".publicKeys = roles.admin;

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc1/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc2/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc3/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc4/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc5/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc6/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc7/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc8/ssh_host_ed25519_key.age".publicKeys = roles.admin;
  "hosts/nuc9/ssh_host_ed25519_key.age".publicKeys = roles.admin;
}
