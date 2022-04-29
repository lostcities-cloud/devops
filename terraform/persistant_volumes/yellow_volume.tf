data "digitalocean_droplet" "yellow_droplet" {
  name = "lostcities-yellow"
}

resource "digitalocean_volume" "yellow_volume" {
  region      = "nyc1"
  name        = "yellow-volume"
  initial_filesystem_type = "ext4"
  size        = 10
}

#resource "digitalocean_volume_attachment" "yellow_volume_attachment" {
#  droplet_id = data.digitalocean_droplet.yellow_droplet.id
#  volume_id  = digitalocean_volume.yellow_volume.id
#}