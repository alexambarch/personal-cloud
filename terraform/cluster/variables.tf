variable "hetzner_token" {
  type        = string
  description = "Your Hetzner API token"
  sensitive   = true
}

variable "cloudinit_server" {
  type        = string
  description = "The path of the cloudinit yaml for the server instances"
}

variable "cloudinit_client" {
  type        = string
  description = "The path of the cloudinit yaml for the client instances"
}

variable "allowlist" {
  type        = list(string)
  description = "A list of IP ranges to allow access to the consul and nomad web UIs"
}
