variable "hetzner_token" {
  type        = string
  description = "Your Hetzner API token"
  sensitive   = true
}

variable "terraform_organization" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}
