data "digitalocean_droplet" "blue_droplet" {
  name = "lostcities-blue"
}

resource "digitalocean_volume" "blue_volume" {
  region      = "nyc1"
  name        = "blue_volume"
  size        = 10
  droplet_id = data.digitalocean_droplet.blue_droplet.id
}