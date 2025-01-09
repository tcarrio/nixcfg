output "script_name" {
  value = local.script_name
  description = "The name of the deployed Worker"
}

output "config" {
  value = data.toml_file.wrangler_toml.content
  description = "The parsed wrangler.toml config"
}

output "domains" {
  value = local.custom_domains
  description = "The domains of the deployed Worker"
}