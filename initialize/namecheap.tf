variable "domain" {
  default = "lostcities.dev"
  type = string
}

resource "namecheap_domain_records" "lostcities-app-domain" {
  domain = "lostcities.dev"
  mode = "OVERWRITE"

  record {
    hostname = "@"
    type = "CNAME"
    address = digitalocean_droplet.yellow_host_droplet.ipv4_address
  }

  record {
    hostname = "www"
    type = "CNAME"
    address = "nginx.service.digital-ocean.consul."
  }

  record {
    hostname = "blue"
    type = "A"
    address = digitalocean_droplet.blue_host_droplet.ipv4_address
  }

  record {
    hostname = "green"
    type = "A"
    address = digitalocean_droplet.green_host_droplet.ipv4_address
  }

  record {
    hostname = "red"
    type = "A"
    address = digitalocean_droplet.red_host_droplet.ipv4_address
  }

  record {
    hostname = "yellow"
    type = "A"
    address = digitalocean_droplet.yellow_host_droplet.ipv4_address
  }
}