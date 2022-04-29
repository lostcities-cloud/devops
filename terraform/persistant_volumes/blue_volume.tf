data "digitalocean_droplet" "blue_droplet" {
  name = "lostcities-blue"
}

resource "digitalocean_volume" "blue_volume" {
  region      = "nyc1"
  name        = "blue-volume"
  size        = 10
  initial_filesystem_type = "ext4"
}

#resource "digitalocean_volume_attachment" "blue_volume_attachment" {
#  droplet_id = data.digitalocean_droplet.blue_droplet.id
#  volume_id  = digitalocean_volume.blue_volume.id
#
#}