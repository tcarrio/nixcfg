# ISOs

All about ISOs! But more specifically, installation image files, in the primary use case for this project.

Building installation media for NixOS servers and desktops using a custom ISO allows the possibility to pre-configure various components, such as authorizing SSH public keys to access the system after it has booted. This is immensely useful for various environments, particular one's with little or no peripheral hardware available.

> ℹ️ This premise is extended for use with cloud providers like [Digital Ocean][] as well. Check it out!

## NixOS ISO Targets

The [flake.nix](../flake.nix) defines various NixOS system configurations under the `outputs.nixosConfigurations` key. In here you will find ISO definitions such as the `iso-console`, `iso-desktop`, and `iso-nuc` image. These build off a specific installer module and configure the base requirements similar to full system definitions. This mostly occurs in the [nixos/default.nix](../nixos/default.nix) which sets up the terminal configuration, disko module, firewall rules, the root user, and more.

You build any system configuration defined there with the command:

```shell
nix build .#nixosConfigurations.$targetName.config.system.build.isoImage

# e.g. nix build .#nixosConfigurations.iso-console.config.system.build.isoImage
```

And output the result of this to `result/`. 

<!-- References -->

[Digital Ocean]: https://digitalocean.com
