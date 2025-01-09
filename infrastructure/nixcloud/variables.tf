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

variable "tf_operation" {
  type        = string
  nullable    = false
  description = "Describes the operation being performed. Allows apply, plan, destroy."
  validation {
    condition     = contains(["plan", "apply", "destroy"], var.tf_operation)
    error_message = "Environment must be one of: apply, plan, destroy"
  }
}