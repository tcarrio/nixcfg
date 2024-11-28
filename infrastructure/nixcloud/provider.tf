provider "digitalocean" {
  # token configured via env var `DIGITALOCEAN_TOKEN`
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "aws" {
  region = "us-east-1"

  # `access_key` configured via env var `AWS_ACCESS_KEY_ID`
  # `secret_key` configured via env var `AWS_SECRET_ACCESS_KEY`

  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "https://${var.cf_acct_id}.r2.cloudflarestorage.com"
  }
}
