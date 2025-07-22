let
  sshMatrix = import ../lib/ssh-matrix.nix { };
  inherit (sshMatrix) groups systems;
  inherit (systems) glass obsidian sktc0 t510 void;

  autoMeshSystems = [
    glass.host
    systems.nix-proxy-droplet.host
  ];
in
{
  "users/tcarrio/ssh.age".publicKeys = groups.privileged_users ++ [ glass.tcarrio glass.host ];
  "services/netbird/token.age".publicKeys = groups.privileged_users ++ autoMeshSystems;
  "services/tailscale/token.age".publicKeys = groups.privileged_users ++ autoMeshSystems;
  # "services/jira-cli/token.age".publicKeys = macos;
  "services/acme/cloudflare.age".publicKeys = groups.privileged_users ++ [ systems.nix-proxy-droplet.host ];
  "services/hoarder/env.age".publicKeys = groups.privileged_users ++ [ systems.obsidian.host ];

  "network-shares/ds418/smb.conf.age".publicKeys = groups.privileged_users;

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc1/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc2/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc3/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc4/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc5/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc6/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc7/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc8/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;
  "hosts/nuc9/ssh_host_ed25519_key.age".publicKeys = groups.privileged_users;

  # spotify + mopidy
  "services/spotify/client.age".publicKeys = groups.users;
}
