# personal-cloud
A Terraform template for creating a tiny Consul + Nomad cluster on Hetzner (us-east/ash)

# Steps
1. Get a Hetzner API token
2. Fill out the template-tfvars
  - `hetzner_token`: your Hetzner API token
  - `server_size`: the Hetzner instance size of your server
  - `client_size`: the Hetzner instance size of your client
  - `allowlist`: a list of CIDR ranges to allow through the firewall to access the APIs and web UIs for Consul and Nomad
3. `tf apply -var-file template-tfvars`

# To Do
- HTTPS
