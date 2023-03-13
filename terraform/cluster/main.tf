terraform {
  cloud {
    organization = "alexambarch"

    workspaces {
      name = "personal-cloud"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

locals {
  everywhere = [
    "::/0",
    "0.0.0.0/0"
  ]

  private_network = [
    "10.0.0.0/16"
  ]

  labels = {
    template = "personal-cloud"
  }
}

resource "hcloud_network" "network" {
  name     = "hcp"
  ip_range = "10.0.0.0/16"
  labels   = local.labels
}

resource "hcloud_firewall" "firewall" {
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = local.everywhere
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = local.everywhere
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = local.everywhere
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = local.everywhere
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "0-65535"
    source_ips = local.private_network
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "0-65535"
    source_ips = local.private_network
  }
}

resource "hcloud_primary_ip" "server_ip" {
  name          = "main"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels        = local.labels
}

resource "hcloud_server" "server" {
  name        = "server"
  image       = "ubuntu-22.04"
  server_type = "cpx11"
  location    = "ash"
  user_data   = ""

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
    ipv4         = hcloud_primary_ip.server_ip.id
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  firewall_ids = [hcloud_firewall.firewall.id]
  labels       = local.labels
}

resource "hcloud_placement_group" "placement-group" {
  name   = "pg1"
  type   = "spread"
  labels = local.labels
}

resource "hcloud_primary_ip" "client_ip" {
  count = 2

  name          = "client-${count.index}-ip"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels        = local.labels
}

resource "hcloud_server" "client" {
  count = 2

  name               = "client-${count.index}"
  image              = "ubuntu-22.04"
  server_type        = "cpx11"
  location           = "ash"
  placement_group_id = hcloud_placement_group.placement-group.id
  user_data          = ""

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
    ipv4         = hcloud_primary_ip.client_ip[count.index]
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.${count.index + 1}"
  }

  firewall_ids = [hcloud_firewall.firewall.id]
  labels       = local.labels
}
