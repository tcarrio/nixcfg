
module "nixos_image_server_worker" {
  source = "../modules/wrangler-deploy"
  
  target_env = "prod"
  config_path = "../nixos-image-server/wrangler.toml"
  cf_acct_id = var.cf_acct_id
  cf_api_token = var.cf_api_token
}

resource "cloudflare_workers_secret" "registry_ro_password" {
  depends_on = [ module.nixos_image_server_worker ]

  account_id  = var.cf_acct_id
  name        = "TOKEN_SECRET"
  script_name = local.script_name
  secret_text = random.image_token.result
}
