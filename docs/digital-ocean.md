# digital-ocean

Digital Ocean is a cloud provider that offers a tantalizing capability that makes it an interesting fit for NixOS hosters: **[Custom Images]**.

This functionality combined with a project like **[nixos-generators]** means we can fairly easily define a base NixOS server configuration that can be used for starting up a new VPS. From there, we need only tell the server what Nix configuration to apply!

## Image definition

The image is defined using a common helper, following a similar pattern to other library functionality like `mkHost`, `mkHome`, but this one is `mkGeneratorImage`. We provide this command with the format of the image, in this case "do" for Digital Ocean, as well as the username and configuration name to utilize.

## Building

The current base image configuration for Digital Ocean is defined under the package name `digital-ocean-base-image`. So you would run:

```bash
nix build .#digital-ocean-base-image

# after completion, new artifacts will be created in result/, namely `result/nixos.qcow2.gz`
```

## Uploading

Currently this has been tested through the web interface, but it would technically be possible to define some Tofu configurations to automate this process. With the build complete, we could target the ISO in `result/`, and push this up. For now, upload the `result/nixos.qcow2.gz` file through the UI.

## Deploying

You could utilize the `doctl` command line tool from Digital Ocean to deploy this image. Once you know the ID of the custom image, you could say something like:

```bash
doctl compute droplet create \
    --image 123456789 \
    --size s-1vcpu-1gb \
    --region nyc3 \
    --vpc-uuid 9cfc8649-dc84-11e8-80bc-3cfdfea9fba1 \
    dotest.carrio.dev
```

To deploy a new VPS from the base NixOS image.

## Applying a Configuration

So many strategies available!

- SSH into the new server, clone the repository, and apply it locally:
  - `git clone https://github.com/tcarrio/nixcfg.git; nixos-rebuild --flake ./nixcfg`
- SSH into the server, then apply it from the remote flake:
  - `nixos-rebuild --flake github:tcarrio/nixcfg`
- Apply it remotely from a trusted source host:
  - `nixos-rebuild --flake .#$targetName --target-host nixos@$targetIpAddress`

