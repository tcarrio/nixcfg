# nixos-image-server

A NixOS image server hosting custom NixOS images.

Built on Cloudflare Workers and R2 storage.

Secured by an opaque token.

Stop trying to access my stuff! These images aren't even valuable!

## Initialization

Running `nix` and `direnv`? Allow the directory

```shell
direnv allow
```

**Wow!**.

## Installing dependencies

This project utilizes `yarn` for managing node packages.

On a NixOS system, which requires native executables be packaged or patched for NixOS due to its unique architecture, you want to utilize the packages installed by the flake. In this case, ignore optional dependencies when installing with `yarn`:

```shell
yarn --ignore-optional
```

If you are not on NixOS and not using Nix, you can simply install the optional dependencies

```shell
yarn
```

# Run the development server

```shell
yarn dev
```

# Deploy the Worker

```shell
yarn deploy
```
