output "image_token" {
  value = random_string.image_token.result
  description = "The image token required for accessing NixOS images via the server"
  sensitive = true
}