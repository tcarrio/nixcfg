locals {
  repository_root = abspath("${path.root}/../..")

  cmd_options = var.tf_operation == "plan" ? ["--dry-run"] : []
}

module "digital_ocean_nixos_image" {
  source = "../modules/nixos-image-build"

  nix_flake_target = "${local.repository_root}#digital-ocean-base-image"
  cmd_options = local.cmd_options
}

## TODO: Enable after fixing Linode image boot issue
# module "linode_nixos_image" {
#   source = "../modules/nixos-image-build"

#   nix_flake_target = "${local.repository_root}#linode-base-image"
#   cmd_options = local.cmd_options
# }
