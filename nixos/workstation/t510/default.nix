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
  ];

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  oxc = {
    desktop = {
      bitwarden.enable = true;
      zed-editor.enable = true;

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
    kernelPackages = pkgs.linuxPackages_zen;
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  ## START LFG: Squeezing performance at all costs when your PC is 15 years old
  boot.kernelParams = [ "mitigations=off" ];
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 70;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;

      # Battery charging behavior to reduce wear on battery health
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  ## END LFG

  networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
