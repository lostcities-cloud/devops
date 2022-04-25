resource "digitalocean_droplet" "red_host_droplet" {
  name   = "lostcities-red"
  image  = "docker-18-04"
  region = "nyc1"
  size   = "s-1vcpu-1gb"
  //user_data = file("setup.sh")

  tags = ["red"]

  ssh_keys = [
    data.digitalocean_ssh_key.default.id,
    data.digitalocean_ssh_key.jenkins_key.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = data.vault_generic_secret.vault_secrets.data["pvt_key"]
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20;",
      "systemctl disable apt-daily.timer",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "kill $(ps aux | grep '/usr/lib/apt/apt.systemd.daily' | awk '{print $2}')  || true",
      "systemctl disable --now apt-daily.timer",
      "rm /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "apt-get update && sudo apt-get install nomad consul",
    ]
  }
}