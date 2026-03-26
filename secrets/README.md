# secrets

This directory maintains all secrets across the repository. It includes the `agenix` target users public keys as well as which `age` secret files should be configured for which targets. In this way, we can safely manage secrets in source control without exposing them.

All `.age` files are encrypted using `age` and committed to source control in their encrypted state.

> _This functionality is a work in progress and not yet fully implemented. As such, expect this to be changed and documented as development continues._

## Running `agenix` commands

All commands must be run while inside of this `secrets/` directory. If you are not in this directory the context of the command will not correctly infer what is being performed.

### Utility commands with Taskfile

The root directory of the repository now contains a `Taskfile.yml` which defines utility tasks for secrets management of `agenix`.

There are tasks for `agenix:rekey` and `agenix:edit`. These should be used for future sections' secrets managements.

### Specifying a private key

The `agenix` command takes a `-i` option where you can pass the path to the private key to utilize for the `agenix` operation. This can be useful if your key is in a non-standard location or your system does not have one configured, and you are relying on the admin keys manually.

## Modifying secrets

This is necessary when the value you want to store in a secret must be modified.

It is important that you do not provide the path to the secret in a local-relative format.

> **Good**: `services/hoarder/env.age`
> **Bad**: `./services/hoarder/env.age`

Run `task agenix:edit $secretPath` or `agenix -e $secretPath` inside the `secrets/` directory.

## Re-keying secrets

This is necessary in multiple scenarios which are often encountered.

- Allowing new users/hosts to decrypt/mount agenix secrets
- Adding new super devices to agenix secrets

### Allowing new users/hosts

The primary location for management of SSH public keys is in [../lib/ssh-matrix.nix][ssh-matrix]. Preferably, this will contain the generated SSH public keys for the host root account (where applicable, like NixOS) along with relevant user account's SSH public keys.

When adding a new user or host, this is where it should be included.

Re-keying will be required if you are including a new host/user public key in the secrets definitions in [secrets.nix].

To re-key agenix, run `task agenix:rekey` or `agenix -r` inside the `secrets/` directory.

## Backup keys

There is a backup `age` key that can be utilized for decryption, re-keying, or other `agenix` interactions.

You will have to bootstrap the `age1f2xkvt5q7qq4yhgya6qagpd02ffyzyp793pm2jq7fxqru3m054dqfpgf2c` key in your environment.

Configure it at `$HOME/.age/key.txt`, owned by `root:root` (Linux/NixOS) or `root:admin` (Darwin/macOS) with permissions `640`.

<!-- References -->

[ssh-matrix]: ../lib/ssh-matrix.nix
[secrets.nix]: ./secrets.nix