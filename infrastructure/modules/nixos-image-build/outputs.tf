output "derivation_path" {
  value = shell_script.nix_build["drvPath"]
  description = "Deriviation path, e.g. /nix/store/293l3jdcj2gf797244d86q2yxyi2hwxy-digital-ocean-image.drv"
}

output "outputs" {
  value = shell_script.nix_build["outputs"]
  description = "A JSON object of outputs from the Nix flake"
}
