locals {
  cmd_flags = join(" ", [for k, v in var.cmd_flags : join(" ", [k, v])])
  cmd_options = join(" ", var.cmd_options)

  build_script = <<-EOF
    nix build ${var.nix_flake_target} ${local.cmd_flags} ${local.cmd_options} --json 2>/dev/null | jq -r .[0]
  EOF
}

data "shell_script" "nix_build" {
  lifecycle_commands {
    read = local.build_script
  }
}