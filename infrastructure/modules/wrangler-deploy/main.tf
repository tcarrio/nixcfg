locals {
  os_path_delimiter = "/" # 😬

  wrangler_path = abspath("${path.root}/${var.config_path}")
  cmd_flags = join(" ", [for k, v in var.wrangler_flags : join(" ", [k, v])])
  cmd_options = join(" ", var.wrangler_options)
  
  path_parts      = split(local.os_path_delimiter, local.wrangler_path)
  cmd_cwd = join(local.os_path_delimiter, slice(local.path_parts, 0, length(local.path_parts) - 1))
  
  target_env = try(
    var.wrangler_flags["-e"], 
    var.wrangler_flags["--env"], 
    null
  )
  env_suffix = local.target_env != null ? "-${local.target_env}" : ""
  
  script_name = "${data.toml_file.wrangler_toml.content["name"]}${local.env_suffix}"

  wrangler_deploy_script = <<-EOF
    cd "${local.cmd_cwd}"

    wrangler deploy ${local.cmd_flags} ${local.cmd_options}
  EOF

  # establish a base object where routes will be defined for this deploy
  base_cfg = try(
    data.toml_file.wrangler_toml.content["env"][local.target_env],
    data.toml_file.wrangler_toml.content,
    {},
  )

  # @example [{ pattern = "dev-images.carrio.dev", custom_domain = true }]
  # @example []
  normalized_route_config_list = try(
    local.base_cfg["routes"],
    [local.base_cfg["route"]],
    [],
  )
  
  # @example ['dev-images.carrio.dev', 'prod-images.carrio.dev']
  custom_domains = toset([
    for route in local.normalized_route_config_list : route.pattern if route.custom_domain
  ])

  # @example 'dev-images.carrio.dev' => 'carrio.dev'
  custom_domain_to_zone_domains = tomap({
    for fqdn in local.custom_domains :
      fqdn =>
        # TODO: This is naive to assume but it works for typical .net, .com, etc
        join(".", slice(split(".", fqdn), length(split(".", fqdn)) - 2, length(split(".", fqdn))))
  })
  # @example 'dev-images.carrio.dev' => 'dev-images'
  custom_domain_to_subdomains = tomap({
    for fqdn in local.custom_domains :
      fqdn =>
        # TODO: This is naive to assume but it works for typical .net, .com, etc
        join(".", slice(split(".", fqdn), 0, length(split(".", fqdn)) - 2))
  })
}

data "toml_file" "wrangler_toml" {
  input = file(local.wrangler_path)
}

data "cloudflare_zone" "wrangler_zones" {
  for_each = local.custom_domain_to_zone_domains
  name = each.value
}

resource "cloudflare_record" "worker_domain_record" {
  for_each = local.custom_domains

  zone_id = data.cloudflare_zone.wrangler_zones[each.value].id
  name    = local.custom_domain_to_subdomains[each.value]
  type    = "CNAME"
  value   = "${local.script_name}.workers.dev"
  proxied = true
  comment = "Worker record for ${local.script_name} to listen on ${each.value}"
}

data "shell_script" "wrangler_deploy" {
  depends_on = [ cloudflare_record.worker_domain_record ]
  lifecycle_commands {
    read = local.wrangler_deploy_script
  }

  environment = {
    CLOUDFLARE_ACCOUNT_ID = var.cf_acct_id
  }

  sensitive_environment = {
    CLOUDFLARE_API_TOKEN = var.cf_api_token
  }
}
