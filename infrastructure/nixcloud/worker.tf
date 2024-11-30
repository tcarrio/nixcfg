module "nixos_image_server_worker" {
  source = "../modules/wrangler-deploy"
  
  config_path = "../nixos-image-server/wrangler.toml"
  wrangler_flags = {
    "--env" = "dev"
  }

  cf_acct_id = var.cf_acct_id
  cf_api_token = var.cf_api_token

  bucket_ids = [ aws_s3_bucket.nixos_images.id ]
}

resource "cloudflare_workers_secret" "registry_ro_password" {
  depends_on = [ module.nixos_image_server_worker ]

  account_id  = var.cf_acct_id
  name        = "TOKEN_SECRET"
  script_name = module.nixos_image_server_worker.script_name
  secret_text = random_string.image_token.result
}
