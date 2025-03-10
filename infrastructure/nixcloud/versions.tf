terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    jq = {
      source = "massdriver-cloud/jq"
      version = "0.2.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
    shell = {
      source = "scottwinkler/shell"
      version = "1.7.10"
    }
  }

  backend "s3" {
    # NOTE: Ensure the follow environment variables are set for S3 backend
    # to utilize Cloudflare R2 buckets:
    #
    # AWS_REGION=us-east-1
    # AWS_ACCESS_KEY_ID=<access-key-id>
    # AWS_SECRET_ACCESS_KEY=<secret-access-key>
    # AWS_ENDPOINT_URL_S3=https://<account-id>.r2.cloudflarestorage.com

    bucket = "nixcfg-tofu"
    key    = "nixcloud/iac/prod/tfstate"
  }
}
