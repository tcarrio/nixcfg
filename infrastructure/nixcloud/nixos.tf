locals {
  repository_root = abspath("${path.root}/../..")
}

module "digital_ocean_nixos_image" {
  source = "../modules/nixos-image-build"

  # alternatively, you can reference the github:tcarrio/nixcfg#digital-ocean-base-image
  nix_flake_target = "${local.repository_root}#digital-ocean-base-image"
}

module "linode_nixos_image" {
  source = "../modules/nixos-image-build"

  # alternatively, you can reference the github:tcarrio/nixcfg#linode-base-image
  nix_flake_target = "${local.repository_root}#linode-base-image"
}
