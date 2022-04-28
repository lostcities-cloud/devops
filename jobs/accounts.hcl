job "accounts" {

  datacenters = ["digital-ocean"]

  group "accounts" {
    network {
      port "service-port" { to = 8090 }
    }

    service {
      name = "accounts"
      port = "service-port"
      tags = ["urlprefix-/api/accounts"]

      check {
        type = "http"
        path = "/api/accounts/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "accounts" {
      driver = "docker"

      env {
        SECRET_MANAGER                 = "true"
        SPRING_PROFILES_ACTIVE         = "stage"
        GOOGLE_APPLICATION_CREDENTIALS = "/home/cnb/.gcreds"
      }

      resources {
        cpu    = 500
        memory = 500
      }

      config {
        image = "ghcr.io/lostcities-cloud/lostcities-accounts:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}