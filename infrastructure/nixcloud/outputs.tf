output "image_token" {
  value = random.image_token.result
  description = "The image token required for accessing NixOS images via the server"
  sensitive = true
}