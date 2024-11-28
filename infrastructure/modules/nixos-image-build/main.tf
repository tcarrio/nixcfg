locals {
  build_script = <<-EOF
    nix build ${var.nix_flake_target} --json 2>/dev/null | jq -r .[0]
  EOF
}

data "shell_script" "nix_build" {
  lifecycle_commands {
    read = local.build_script
  }
}