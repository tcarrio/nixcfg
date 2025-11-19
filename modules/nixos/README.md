# modules

The `nixos/modules` directory houses NixOS modules, unsurprisingly.

## Comparison to mixins

The major difference between modules and mixins (see `nixos/mixins`) is that mixins are not typically configurable, by applying a mixin you get an opinionated declaration applied to the current NixOS module.

Importing a NixOS module may have side effects, if certain defaults are `true` for e.g. `oxc.services.some-service.enable`, but often times the defaults are `false`.

Importing a mixin will have side effects, and would instead explicitly go about enabling `some-service`, however that would be done.

## How to use

For NixOS modules, these provide a similar interface to the NixOS modules out of the box. Consider `services.xserver.enable`: you can set this to `true` and you have enabled the graphical environment via Xorg Server (or Wayland).

All of the custom NixOS modules defined here utilize options defined under `oxc`. So you may see `oxc.tailscale.enable`, which will install the Tailscale CLI, enable the `tailscaled` service, and configure additional ports for access in the firewall.

## What do I need to import then to use these?

Nothing! The root `default.nix` imports all modules, and if a graphical desktop environment was defined (via the `desktop` parameter) then it will also process all `desktop/` modules as well. If a system does not have a graphical environment, these will simply not be available or even parsed.

Head back up to the `How to use` section for more info on interacting with them.