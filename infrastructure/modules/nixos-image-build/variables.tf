variable "nix_flake_target" {
  type        = string
  nullable    = false
  description = "The Nix flake target to build"
}

variable "cmd_flags" {
  type        = map(string)
  default     = {}
  description = "Additional flags to pass to the command"
}

variable "cmd_options" {
  type        = list(string)
  default     = []
  description = "Additional options to pass to the command"
}