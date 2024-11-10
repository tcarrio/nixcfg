terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket = "nixcfg-carrio-state"
    key    = "cloud/iac/prod/tfstate"
  }
}
