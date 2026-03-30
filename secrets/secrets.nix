let
  sshMatrix = import ../lib/ssh/matrix.nix;

  inherit (sshMatrix) groups systems;
  inherit (systems) glass;

  mapSetValues = f: set: map f (map (key: set.${key}) (builtins.attrNames set));

  allSystemHostKeys = systems
    |> mapSetValues (system: system.host or null)
    |> builtins.filter (host: host != null);

  matches = pattern: string: string
    |> builtins.match pattern
    |> builtins.isList;

  # Various key type matchers
  isAgeKey = matches "age[0-9a-z]+";
  isRsaKey = matches "ssh-rsa[[:space:]].*";
  isEd25519 = matches "ssh-ed25519[[:space:]].*";
  # 'sk-' prefixed keys require security key confirmation
  isEcdsaKey = matches "(|sk-)ecdsa-sha2-nistp256(@openssh\\.com)?[[:space:]].*";

  matcherMap = {
    age = isAgeKey;
    rsa = isRsaKey;
    ed25519 = isEd25519;
    ecdsa = isEcdsaKey;
    enclave = isEcdsaKey;
    yubikey = isEcdsaKey;
  };

  # Determine matcher function by the key type.
  # TODO: More extensive checking, right now this incorporates only what matters for my repo
  matcherByKeyType = type: (matcherMap."${type}" or (_: true));

  filterByKeyType = keyTypes: keys:
    let
      keyInKeyTypes = key: (
        builtins.any
          (keyType: matcherByKeyType keyType key)
          keyTypes
      );
    in
      builtins.filter keyInKeyTypes keys;

  agenixSupportedKeyTypes = ["age" "rsa" "ed25519"];
  agenixSupportedKeyFilter = filterByKeyType agenixSupportedKeyTypes;

  autoMeshSystems = allSystemHostKeys;

  ageKeys = {
    backup = "age1f2xkvt5q7qq4yhgya6qagpd02ffyzyp793pm2jq7fxqru3m054dqfpgf2c";
    # macOS host-specific keys
    # gokin = TODO
  };

  backupKeys = with ageKeys; [
    backup
  ];

  base = groups.privileged_users ++ backupKeys ++ groups.backup_keys;

  mkPublicKeys = extraKeys: { publicKeys = agenixSupportedKeyFilter (base ++ extraKeys); };
in
{
  "users/tcarrio/ssh.age" = mkPublicKeys [];
  "services/netbird/token.age" = mkPublicKeys autoMeshSystems;
  "services/tailscale/token.age" = mkPublicKeys autoMeshSystems;
  "services/acme/cloudflare.age" = mkPublicKeys [ ];
  "services/hoarder/env.age" = mkPublicKeys [ ];

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
