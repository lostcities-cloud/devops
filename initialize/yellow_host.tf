




resource "digitalocean_droplet" "yellow_host_droplet" {
  name   = "lostcities-yellow"
  image  = "docker-18-04"
  region = "nyc1"
  size   = "s-1vcpu-1gb"
  //user_data = file("setup.sh")

  tags = ["yellow"]


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
      "sleep 10;",
      "systemctl disable apt-daily.timer",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "kill $(ps aux | grep '/usr/lib/apt/apt.systemd.daily' | awk '{print $2}')  || true",
      "systemctl disable --now apt-daily.timer",
      "rm /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend",

      // TODO put this in ansible with lookup: https://docs.ansible.com/ansible/2.9/plugins/lookup/hashi_vault.html
      "cat << EOF > /var/opt/nginx/options-ssl-nginx.conf\n${data.vault_generic_secret.vault_secrets.data["options-ssl-nginx.conf"]}\n\nEOF",
      "cat << EOF > /var/opt/nginx/fullchain.pem\n${data.vault_generic_secret.vault_secrets.data["fullchain.pem"]}\n\nEOF",
      "cat << EOF > /var/opt/nginx/privkey.pem\n${data.vault_generic_secret.vault_secrets.data["privkey.pem"]}\n\nEOF",
      "cat << EOF > /var/opt/nginx/ssl-dhparams.pem\n${data.vault_generic_secret.vault_secrets.data["ssl-dhparams.pem"]}\n\nEOF",
    ]
  }
}

/var/opt/nginx/