variable "lost_cities_account" {
  type = string
  default = "lostcities-accounts"
}

resource "digitalocean_droplet" "accounts_host" {
  image  = "docker-18-04"
  name   = var.lost_cities_account
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
      //"docker pull ${var.oci_path}"
      "export SECRET_MANAGER=true",
      "export SPRING_PROFILES_ACTIVE=dev",
      "export GOOGLE_APPLICATION_CREDENTIALS=~/.gcreds",
      "cat > ~/.gcreds <<EOL\n ${data.vault_generic_secret.vault_secrets.data["google_key"]} \nEOL",
      "docker pull ghcr.io/lostcities-cloud/lostcities-accounts:latest",
      "docker run -d -e JAVA_OPTS=\"-XX:ActiveProcessorCount=1 -Xmx725M -Xss256K\" -e GOOGLE_APPLICATION_CREDENTIALS=\"/home/cnb/.gcreds\" -it --memory=\"1G\" -v /root/.gcreds:/home/cnb/.gcreds ghcr.io/lostcities-cloud/lostcities-accounts:latest"
    ]
  }
}

resource "google_secret_manager_secret" "accounts_host_url_secret" {
  secret_id = "accounts_host_url"

  replication {
    user_managed {
      replicas {
        location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "accounts_host_url_secret" {
  secret = google_secret_manager_secret.accounts_host_url_secret.id

  secret_data = digitalocean_droplet.accounts_host.ipv4_address
}

resource "google_secret_manager_secret" "accounts_jwt_secret" {
  secret_id = "accounts_jwt_secret"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "accounts_jwt_secret_version" {
  secret = google_secret_manager_secret.accounts_jwt_secret.id

  secret_data = "secret-data"
}
