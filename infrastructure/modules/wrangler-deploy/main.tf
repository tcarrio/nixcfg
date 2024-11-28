locals {
  wrangler_path = abspath("${path.root}/${var.config_path}")
  cmd_flags = join(" ", [for k, v in var.wrangler_flags : join(" ", [k, v])])
  cmd_options = join(" ", var.wrangler_options)
  
  target_env = try(
    var.wrangler_flags["-e"], 
    var.wrangler_flags["--env"], 
    null
  )
  env_suffix = local.target_env != null ? "-${local.target_env}" : ""
  
  script_name = "${data.toml_file.wrangler_toml.content["name"]}${local.env_suffix}"

  wrangler_deploy_script = <<-EOF
    wrangler deploy ${cmd_flags} ${cmd_options}
  EOF
}

data "toml_file" "wrangler_toml" {
  input = file(local.wrangler_path)
}

data "shell_script" "wrangler_deploy" {
  lifecycle_commands {
    read = local.wrangler_deploy_script
    update = local.wrangler_deploy_script
  }

  environment = {
    CLOUDFLARE_ACCOUNT_ID = var.cf_acct_id
  }

  sensitive_environment = {
    CLOUDFLARE_API_TOKEN = var.cf_api_token
  }
}
