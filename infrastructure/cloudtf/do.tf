resource "digitalocean_custom_image" "nixos-base-image" {
  name    = "nixos-base-image"
  url     = ""
  regions = ["nyc3"]
}