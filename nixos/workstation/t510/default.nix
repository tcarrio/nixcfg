# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        500GB SSD

{ inputs, lib, pkgs, ... }: {
  imports = [
    (import ../t510-headless/disks.nix { })

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../mixins/hardware/grub-legacy-boot.nix
    ../../mixins/services/pipewire.nix
    ../../mixins/services/t510-dvd-nbd-tailscale-service.nix
  ];

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  oxc = {
    desktop = {
      bitwarden.enable = true;
      # zed.enable = true;

      vscode.support = {
        deno = true;
      };

      # override default browser
      zen-browser.enable = true;
      google-chrome.enable = lib.mkForce false;
      chromium.enable = lib.mkForce false;
      firefox.enable = lib.mkForce false;
    };
    services = {
      tailscale.enable = true;
      wait-online.enable = false;
    };
    containerisation = {
      enable = true;
      engine = "podman";
    };
    virtualisation.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

