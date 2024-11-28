output "derivation_path" {
  value = data.shell_script.nix_build.output["drvPath"]
  description = "Derivation path, e.g. /nix/store/293l3jdcj2gf797244d86q2yxyi2hwxy-digital-ocean-image.drv"
}

output "outputs" {
  value = data.shell_script.nix_build.output["outputs"]
  description = "A JSON object of outputs from the Nix flake"
}
