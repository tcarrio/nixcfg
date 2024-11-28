variable "cf_api_token" {
  type        = string
  nullable    = false
  description = "The Cloudflare API token to use for the wrangler CLI"
}

variable "cf_acct_id" {
  type        = string
  nullable    = false
  description = "The Cloudflare account ID to use for the wrangler CLI"
}

variable "config_path" {
  type        = string
  nullable    = false
  description = "The path to the Wrangler config (wrangler.toml) relative to module root"
}

variable "wrangler_flags" {
  type        = map(string)
  default     = {}
  description = "Additional flags to pass to the wrangler deploy command"
}

variable "wrangler_options" {
  type        = list(string)
  default     = []
  description = "Additional options to pass to the wrangler deploy command"
}