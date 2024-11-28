variable "cf_acct_id" {
  type        = string
  nullable    = false
  description = "Cloudflare account ID"
  sensitive = true
}

variable "cf_api_token" {
  type        = string
  nullable    = false
  description = "Cloudflare API token"
  sensitive = true
}
