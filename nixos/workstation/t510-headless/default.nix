# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        500GB SSD

_: {
  imports = [
    (import ./disks.nix { })
    ../../iso/iso-console
  ];
}
