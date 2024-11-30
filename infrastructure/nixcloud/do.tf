locals {
  region = "nyc3"

  acct_id = var.cf_acct_id
  bucket_name = aws_s3_bucket.nixos_images.id
}

data "digitalocean_ssh_key" "glass_ssh_key" {
  name = "glass-nix"
}

resource "digitalocean_custom_image" "nixos_base_image" {
  depends_on = [ aws_s3_object.digital_ocean_base_images ]

  name    = "nixos-base-image"
  # TODO: Use image-server worker
  url     = "https://dev-images.carrio.dev/images/${local.do_image_filename}?token=${random_string.image_token.result}"
  regions = [local.region]
}

resource "digitalocean_droplet" "nixos_proxy_droplet" {
  image    = digitalocean_custom_image.nixos_base_image.id
  name     = "nixos-proxy-droplet-tofu"
  region   = local.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.glass_ssh_key.id]
}


resource "digitalocean_firewall" "web_ssh" {
  name = "web_and_ssh_administration"

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