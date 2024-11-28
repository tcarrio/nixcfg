provider "shell" {
    environment = {
      # environment variables will be visible in logs
    }
    sensitive_environment = {
      # these will be hidden from logs
    }
    interpreter = ["/bin/sh", "-c"]
    enable_parallelism = false
}