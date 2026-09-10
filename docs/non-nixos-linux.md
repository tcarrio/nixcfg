# Non-NixOS Linux Setup (Ubuntu + Nix + Home Manager)

Runbook for standing up a workstation-grade Linux machine managed entirely
by Nix at the user level: the system layer (kernel, drivers, desktop
environment, daemons) stays with the distro (apt), and everything developer
-facing — shells, editors, CLIs, user services, fonts, dotfiles — comes from
[this flake](../flake.nix) via standalone home-manager.

There is no `nixos-rebuild` / `darwin-rebuild` equivalent here. The loop is:

```fish
rebuild-home   # home-manager switch -b backup --flake ~/0xc/nixcfg#<user>@<host>
```

Host/user-agnostic by design; `<user>@<host>` below is whichever
`homeConfigurations` entry targets this machine.

## Fast path

`scripts/shell/bootstrap-linux-machine.sh` automates sections 1–3 below:
multi-user Nix install, cloning the flake to `~/0xc/nixcfg`, and the first
`home-manager init`/`switch`. Run it, then continue at section 4.

```fish
bash scripts/shell/bootstrap-linux-machine.sh
```

For NixOS machines (not covered by this doc),
`scripts/shell/bootstrap-nixos-machine.sh` is the equivalent entry point.

## 1. Install Nix (multi-user)

https://nixos.org/download/ — use the multi-user (daemon) installation:

```fish
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Enable flakes for your user:

```fish
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes pipe-operators\n' >> ~/.config/nix/nix.conf
```

## 2. Clone and first switch

```fish
# https for a brand-new machine with no SSH keys yet; switch to SSH later
git clone https://github.com/tcarrio/nixcfg.git ~/0xc/nixcfg
cd ~/0xc/nixcfg

# Bootstrap home-manager from the registry, then activate
nix run home-manager -- switch -b backup --flake .#<user>@<host>
```

After the first switch, `home-manager` and `rebuild-home` are on PATH from
the profile itself.

## 3. Fish as the login shell

```fish
sudo fish -c 'echo ~/.nix-profile/bin/fish >> /etc/shells'  # literal profile path, survives bumps
sudo chsh -s ~/.nix-profile/bin/fish $USER
```

Log out and back in. (GNOME terminal and VS Code inherit the shell from the
session, so a full re-login is the reliable point for everything below that
depends on PATH or environment.)

## 4. apt prerequisites (one-time, sudo)

Base tooling the user-level config expects from the system (the bootstrap
script's Nix install and clone steps also want `curl` and `git` here):

```fish
sudo apt-get update
sudo apt-get install -y curl git
```

Third-party repositories (each installs a signing key + sources.list entry;
follow the vendor's current instructions):

| Repo | Provides | Notes |
|---|---|---|
| Microsoft (packages.microsoft.com) | `code` (VS Code) | Optional — `apt-sync` installs `code` via the stable-redirect `.deb` URL mapping without the repo |
| `ppa:mkasberg/ghostty-ubuntu` | `ghostty` | Optional — `apt-sync` installs ghostty via the community `.deb` URL mapping (version + `${ubuntu_version}` runtime placeholder) without the repo; official Ubuntu repos carry ghostty only from 26.04. Graphical nix packages need nixGL on non-NixOS, so the binary is deb-managed while home-manager still renders its config and themes |
| Google Chrome | `google-chrome-stable` | Optional |
| Docker / Podman upstream | container daemons | Or use the distro's `docker.io` / `podman` |

Container daemons and group membership (the CLIs — `lazydocker`, `dive` —
come from home-manager; only the daemon is apt's business):

```fish
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER   # re-login to take effect
```

Flatpak, if you opt into it later:

```fish
sudo apt-get install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

## 5. Apt management (`apt-sync`)

Apt state on these hosts is managed homebrew-style: a declarative set of
repositories and packages applied non-deterministically, with no cleanup on
removal — uninstalling is a manual `sudo apt remove <pkg>` (and removing a
repository definition leaves its keyring/sources files in place).

Three option surfaces in the host's home-manager file:

- `oxc.apt.repositories.<name>` — custom apt repositories: the GPG public
  key is defined inline in the configuration (deterministic, like any flake
  derivation input), dearmored at build time, and installed to
  `/etc/apt/keyrings/<name>.gpg`; the sources entry lands in
  `/etc/apt/sources.list.d/<name>.list`; then `apt update`. Registration is
  cmp-guarded — converged repositories cost zero sudo
- `oxc.apt.packages` — plain names resolved against the host's configured
  apt repositories (stock Ubuntu/Debian plus any managed repositories)
- `oxc.apt.sources.<name>.url` — per-architecture `.deb` download URLs for
  packages with no available repository (e.g. VS Code via the
  `code.visualstudio.com/sha/download` stable redirect; `${ubuntu_version}`
  placeholder supported for URLs embedding the Ubuntu release). Prefer a
  repository when the vendor ships one

Resolution order per package: managed repository (plain name after repo
setup + update) > URL mapping > plain `apt install <name>`. A package with
no resolvable source fails with a pointer to the missing prerequisite.

Hosts can converge automatically — `oxc.apt.onActivation.enable` runs
apt-sync as part of every `home-manager switch` (nix-darwin homebrew-style:
after the profile installs; idempotent, so a converged system installs
nothing, runs no apt update, and never prompts for sudo; a missing package
or changed repository prompts interactively — run switches from a
terminal). Manual use:

```fish
task apt:sync   # or: apt-sync
apt-list        # show the managed set
```

## 6. gpg-agent as the SSH agent

home-manager configures `services.gpg-agent` with `enableSshSupport` and
points `SSH_AUTH_SOCK` at `${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh`.

To authenticate with a gpg authentication key, add its keygrip to the agent
(per key, once):

```fish
gpg --list-secret-keys --with-keygrip
# then, for the [A] (authentication) subkey's keygrip:
echo <KEYGRIP> >> ~/.gnupg/sshcontrol
```

`ssh-add -l` against the agent should then list the key's OpenSSH form.

## 7. Fonts

home-manager installs nerd-fonts into the user profile and enables
fontconfig. If an application (notably sandboxed flatpaks/snaps) doesn't
pick them up, either install that app's font dependency at the system level
or copy into `~/.local/share/fonts` and `fc-cache -fv`.

## 8. NVIDIA (if applicable)

Use the distro driver stack (`ubuntu-drivers autoinstall` or the "Additional
Drivers" GNOME panel). Do not mix nixpkgs NVIDIA packages with the system
driver.

## 9. What stays manual

By design, this setup leaves the following to the distro and to one-time
manual steps (this is the trade of no system-level Nix):

- apt repository/key management (step 4)
- daemon enablement: `sudo systemctl enable --now docker`
- udev rules for exotic hardware (copy into `/etc/udev/rules.d/` — the
  streamdeck and roccat rules from `nixos/mixins/hardware/` are the usual
  suspects), then `sudo udevadm control --reload`
- GNOME extensions/themes outside dconf
- Remote NixOS server rebuilds work from this host via `nixos-rebuild-ng`
  (installed by home-manager), same `--target-host` flow as the Taskfile's
  `nixos:deploy` task.

## 10. Troubleshooting

- **GUI apps don't see nix-installed binaries**: the multi-user installer's
  `/etc/profile.d/nix.sh` only reaches login bash shells. home-manager
  covers two layers: fish bootstraps both profile bins onto PATH itself
  (`fish/conf.d/00-nix-profile-path.fish` — effective immediately), and
  `environment.d/10-nix-profile.conf` exports them session-wide. The
  environment.d layer is only read at user-manager start; if it hasn't
  taken effect after logout/login (the user manager survives logout on
  Ubuntu/GNOME), either reboot or run `loginctl terminate-user $USER`
  from a TTY outside the graphical session.
- **`nix` command not found in a GUI terminal**: the nix CLI lives in the
  daemon profile (`/nix/var/nix/profiles/default/bin`), not the user
  profile — both are covered by the mechanisms above.
- **`apt-sync: command not found`**: it's only rendered when `oxc.apt`
  manages something; check the host file sets repositories/packages/sources.
- **gpg-agent SSH socket missing**: `systemctl --user status gpg-agent` and
  `gpgconf --launch gpg-agent` (the socket directory lives under
  `$XDG_RUNTIME_DIR`, which requires a proper login session).
