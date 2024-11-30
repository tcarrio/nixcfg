locals {
  cmd_flags = join(" ", [for k, v in var.cmd_flags : join(" ", [k, v])])
  cmd_options = join(" ", var.cmd_options)

  artifact_key_script = <<-EOF
    nix build ${var.nix_flake_target} --dry-run --json 2>/dev/null | jq -r .[0].outputs
  EOF
  build_script = <<-EOF
    nix build ${var.nix_flake_target} ${local.cmd_flags} ${local.cmd_options} --json 2>/dev/null | jq -r .[0]
  EOF
}

# Provides a faster cache miss mechanism to determine if a build will be necessary
data "shell_script" "nix_build_artifact_key" {
  lifecycle_commands {
    read = local.artifact_key_script
  }
}

resource "shell_script" "nix_build" {
  lifecycle_commands {
    create = local.build_script
    delete = "echo \"Unnecessary deletion - Skipping\""
  }

  triggers = {
    when_value_changed = data.shell_script.nix_build_artifact_key.output["out"]
  }
}