resource "digitalocean_droplet" "matches_host" {
  image  = "docker-18-04"
  name   = "lostcities-matches"
  region = "nyc1"
  size   = "s-1vcpu-1gb"

  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = data.vault_generic_secret.vault_secrets.data["pvt_key"]
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export SPRING_PROFILES_ACTIVE=dev",
      "export GOOGLE_APPLICATION_CREDENTIALS=~/.gcreds",
      "export SECRET_MANAGER=true",
      "cat > ~/.gcreds <<EOL\n ${data.vault_generic_secret.vault_secrets.data["google_key"]} \nEOL",
      "docker run -d -e JAVA_OPTS=\"-XX:ActiveProcessorCount=1 -Xmx725M -Xss256K\" -e GOOGLE_APPLICATION_CREDENTIALS=\"/home/cnb/.gcreds\" -it --memory=\"1G\" -v /root/.gcreds:/home/cnb/.gcreds ghcr.io/lostcities-cloud/lostcities-matches:latest"
    ]
  }
}

resource "google_secret_manager_secret" "matches_host_url_secret" {
  secret_id = "matches_host_url"

  replication {
    user_managed {
      replicas {
        location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "matches_host_url_secret" {
  secret = google_secret_manager_secret.matches_host_url_secret.id

  secret_data = digitalocean_droplet.matches_host.ipv4_address
}