variable "hetzner_token" {
  type        = string
  description = "Your Hetzner API token"
  sensitive   = true
}

variable "server_size" {
  type        = string
  description = "The Hetzner instance size for the server node"
  default     = "cpx11"
}

variable "client_size" {
  type        = string
  description = "The Hetzner instance size for the client node"
  default     = "cpx11"
}

variable "allowlist" {
  type        = list(string)
  description = "A list of IP ranges to allow access to the consul and nomad web UIs"
}
