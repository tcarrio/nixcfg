resource "random_string" "image_token" {
  length = 32
  special = false

  min_lower = 4
  min_upper = 4
  min_numeric = 4
}