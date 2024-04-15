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
      version = "1.46.1"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

locals {
  os_image = "ubuntu-22.04"

  everywhere = [
    "::/0",
    "0.0.0.0/0"
  ]

  private_network = [
    "10.0.0.0/16",
    "100.64.0.0/10"
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

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "us-east"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "firewall" {
  name = "Cluster Firewall"
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = local.everywhere
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "any"
    source_ips = local.private_network
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "any"
    source_ips = local.private_network
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "any"
    source_ips = var.allowlist
  }

  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "any"
    destination_ips = var.allowlist
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "any"
    destination_ips = var.allowlist
  }
}

resource "hcloud_primary_ip" "server_ip" {
  name          = "server-ip"
  datacenter    = "ash-dc1"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels        = local.labels
}

resource "hcloud_server" "server" {
  name        = "server"
  image       = local.os_image
  server_type = var.server_size
  location    = "ash"
  user_data   = file("${path.module}/cloud-init/server.yaml")

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

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_placement_group" "placement-group" {
  name   = "pg1"
  type   = "spread"
  labels = local.labels
}

resource "hcloud_primary_ip" "client_ip" {
  count = 2

  datacenter    = "ash-dc1"
  name          = "client-${count.index}-ip"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels        = local.labels
}

resource "hcloud_server" "client" {
  count = 2

  name               = "client-${count.index}"
  image              = local.os_image
  server_type        = var.client_size
  location           = "ash"
  placement_group_id = hcloud_placement_group.placement-group.id
  user_data          = file("${path.module}/cloud-init/client.yaml")

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
    ipv4         = hcloud_primary_ip.client_ip[count.index].id
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.${count.index + 2}"
  }

  firewall_ids = [hcloud_firewall.firewall.id]
  labels       = local.labels

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}
