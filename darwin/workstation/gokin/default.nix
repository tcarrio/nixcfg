# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ pkgs, ... }:
{
  # Bluebox has an unfree license
  nixpkgs.config.allowUnfree = true;

  # TODO: Remote builds on orca (x86_64-linux) over ssh-ng:// for Linux
  # packages (e.g. pkgs.robovac) from this Mac. Requires:
  #   - nix.buildMachines entry for orca here (daemon reads /etc/nix/machines)
  #   - a non-interactive SSH key for the build hook (Tailscale SSH's browser
  #     recheck hangs unattended builds) + orca's host key in known_hosts
  #   - orca signing its store (nix.settings.secret-key-files via agenix) with
  #     its public key in this host's trusted-public-keys, or the daemon
  #     rejects copied-back outputs as unsigned
  # Verified working end-to-end manually (build + copy back) on 2026-08-28.

  sk.enable = false;
  oxc.homebrew.enable = true;
  oxc.homebrew.defaults = true;
  oxc.services.colima = {
    enable = true;
    automaticBoot = true;
  };

  environment.systemPackages =
    (with pkgs.unstable; [
      openssh
      freetube
    ])
    ++ [
      pkgs.bluebox
    ];

  homebrew.casks = [
    "opencode-desktop"
    "synology-drive"
  ];
}
