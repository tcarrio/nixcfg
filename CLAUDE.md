# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive Nix configuration repository that manages both NixOS (Linux) and nix-darwin (macOS) systems using Nix Flakes. The repository uses a modular, mixin-based architecture for maximum composability and reusability across platforms.

## Core Commands

### System Rebuilds
- **NixOS**: `rebuild-host` - Runs `sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg`
- **macOS**: `rebuild-host` - Runs `sudo darwin-rebuild switch --flake $HOME/0xc/nixcfg#$(hostname)`
- **Home Manager**: `rebuild-home` - Runs `home-manager switch -b backup --flake $HOME/0xc/nixcfg`
- **Full rebuild**: `rebuild-all` - Runs garbage collection + host + home rebuilds

### ISO Building
- **Desktop ISO**: `rebuild-iso-desktop` - Builds full desktop environment ISO
- **Console ISO**: `rebuild-iso-console` - Builds console-only ISO
- **NUC ISO**: `rebuild-iso-nuc` - Builds NUC-specific ISO

### Development
- **Lock updates**: `rebuild-lock` - Updates flake.lock file
- **Garbage collection**: `nix-gc` - Cleans up old generations
- **Formatting**: `nix fmt` - Uses nix-formatter-pack for code formatting

### Infrastructure Management (when in /infrastructure)
- **Task runner**: `task` - Uses Taskfile.yml for Terraform/OpenTofu operations
- **Initialize**: `task nixcloud:tf:init` - Initialize Terraform backend
- **Apply/Plan**: `task nixcloud:tf:apply` or `task nixcloud:tf:plan`

## Architecture Overview

### Directory Structure
- **`/nixos/`** - NixOS system configurations and mixins
- **`/darwin/`** - nix-darwin macOS configurations
- **`/home-manager/`** - Platform-agnostic user configurations
- **`/lib/`** - Shared helper functions and utilities
- **`/pkgs/`** - Custom package definitions
- **`/overlays/`** - Package overlays and modifications
- **`/infrastructure/`** - Terraform/OpenTofu infrastructure as code
- **`/shells/`** - Development shell environments
- **`/secrets/`** - agenix encrypted secrets

### Mixin System
The repository uses a sophisticated mixin pattern for composable configurations:

**Console Mixins**: Shell tools, CLI applications, development environment
**Desktop Mixins**: GUI applications, desktop environments (GNOME, KDE6, MATE, Pantheon, i3, Hyprland)
**Services Mixins**: System services (SSH, Tailscale, Docker, networking)
**Hardware Mixins**: Hardware-specific configurations (GPU, devices, boot)
**Users Mixins**: User-specific configurations and customizations

### Platform Support
- **NixOS**: Linux systems (workstations, servers, ISO images)
- **nix-darwin**: macOS systems
- **Architectures**: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin

## Key Helper Functions

Located in `/lib/helpers.nix`:
- **`mkHost`** - Creates NixOS system configurations
- **`mkDarwin`** - Creates nix-darwin configurations
- **`mkHome`** - Creates Home Manager configurations
- **`mkGeneratorImage`** - Creates cloud images (Digital Ocean, Linode)
- **`mkSdImage`** - Creates Raspberry Pi SD card images

## Custom Packages

Available through `pkgs` in configurations:
- **`nixvim`** - Pre-configured Neovim with LSP, Tokyo Night theme
- **`gqurl`** - GraphQL URL utility (built with Bun)
- **`kube-rsync`** - Kubernetes rsync utility
- **`zeit`** - Time tracking tool

## Configuration Management

### Secrets
- Uses **agenix** for encrypted secrets management
- Secrets stored in `/secrets/` directory
- Age keys managed through `/lib/age-matrix.nix`

### Caches
- **nixos.org** - Official Nix binary cache
- **cache.garnix.io** - Garnix CI cache
- **nix-community.cachix.org** - Community packages
- **nix-darwin.cachix.org** - nix-darwin packages

### State Management
- Current state version: **24.05**
- All systems use unified state version for consistency
- Garbage collection configured for automatic cleanup

## System Types

### NixOS Systems
- **Workstations**: Desktop/laptop configurations in `/nixos/workstation/`
- **Servers**: Server configurations in `/nixos/server/`
- **ISO Images**: Live images in `/nixos/iso/`

### macOS Systems
- **Workstations**: Mac configurations in `/darwin/workstation/`
- **Shared mixins**: Symlinked to `/nixos/mixins/` for cross-platform compatibility

## Development Workflow

1. **Make changes** to configurations or mixins
2. **Test locally** using `rebuild-host` or `rebuild-home`
3. **Format code** using `nix fmt` before committing
4. **Update locks** periodically with `rebuild-lock`
5. **Build ISOs** for testing with `rebuild-iso-*` commands

## Important Notes

- Repository is cloned to `~/0xc/nixcfg` by convention
- Fish shell is used across all platforms with consistent aliases
- Configurations support both stable (25.11) and unstable nixpkgs channels
- Infrastructure uses OpenTofu with Cloudflare R2 backend for state storage
- All systems use systemd-boot or GRUB for booting
- Cross-compilation supported for building across architectures

## Testing and Validation

- No formal test framework - validation through successful rebuilds
- ISO images can be tested in virtual machines
- Remote builds supported for resource-intensive compilation
- Recovery ISOs available for system rescue scenarios
