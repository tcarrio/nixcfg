locals {
  region = "nyc3"

  acct_id = var.cf_acct_id
  bucket_name = aws_s3_bucket.nixos_images.name
  image_object_name = "id"
}

data "digitalocean_ssh_key" "example" {
  name = "glass-nix"
}

resource "digitalocean_custom_image" "nixos_base_image" {
  name    = "nixos-base-image"
  url     = "https://${var.cf_acct_id}.r2.cloudflarestorage.com/${local.bucket_name}/${local.image_object_name}"
  regions = [local.region]
}

resource "digitalocean_custom_image" "flatcar" {
  name    = "flatcar"
  url     = "https://stable.release.flatcar-linux.net/amd64-usr/2605.7.0/flatcar_production_digitalocean_image.bin.bz2"
  regions = [local.region]
}

resource "digitalocean_droplet" "nixos_proxy_droplet" {
  image    = digitalocean_custom_image.nixos_base_image.id
  name     = "nixos-proxy-droplet"
  region   = local.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [12345]
}


resource "digitalocean_firewall" "proxy_server" {
  name = "https_and_ssh_administration"

  droplet_ids = [digitalocean_droplet.nixos_proxy_droplet.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}