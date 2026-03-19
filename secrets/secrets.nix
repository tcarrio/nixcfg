let
  sshMatrix = import ../lib/ssh/matrix.nix;
  inherit (sshMatrix) groups systems;
  inherit (systems) glass;

  mapSetValues = f: set: map f (map (key: set.${key}) (builtins.attrNames set));

  allSystemHostKeys = builtins.filter (host: host != null) (
    mapSetValues (system: if (system ? host) then system.host else null) systems
  );

  autoMeshSystems = allSystemHostKeys;

  backupKeys = [
    "age1f2xkvt5q7qq4yhgya6qagpd02ffyzyp793pm2jq7fxqru3m054dqfpgf2c"
  ];

  base = groups.privileged_users ++ backupKeys ++ groups.backup_keys;

  mkPublicKeys = extraKeys: { publicKeys = base ++ extraKeys; };
in
{
  "users/tcarrio/ssh.age" = mkPublicKeys [
    glass.tcarrio
    glass.host
  ];
  "services/netbird/token.age" = mkPublicKeys autoMeshSystems;
  "services/tailscale/token.age" = mkPublicKeys autoMeshSystems;
  "services/acme/cloudflare.age" = mkPublicKeys [ ];
  "services/hoarder/env.age" = mkPublicKeys [ systems.obsidian.host ];

  "network-shares/ds418/smb.conf.age" = mkPublicKeys [ ];

  # primarily maintained via agenix for convenience of scripting automations
  "hosts/nuc0/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc1/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc2/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc3/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc4/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc5/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc6/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc7/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc8/ssh_host_ed25519_key.age" = mkPublicKeys [ ];
  "hosts/nuc9/ssh_host_ed25519_key.age" = mkPublicKeys [ ];

  # spotify + mopidy
  "services/spotify/client.age" = mkPublicKeys groups.users;
}
