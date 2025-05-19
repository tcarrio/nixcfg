# Legacy module. This defers entirely to nixos-hardware
# See https://github.com/NixOS/nixos-hardware

{ inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];
}

