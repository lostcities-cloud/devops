job "matches" {

  datacenters = ["digital-ocean"]

  group "matches" {
    network {
      port "service-port" {
        to = 8091
      }
    }

    service {
      name = "matches"
      tags = ["default", "urlprefix-/api/matches"]
      port = "service-port"
      check {
        type = "http"
        path = "/api/matches/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "matches" {
      driver = "docker"

      env {
        SECRET_MANAGER                 = "true"
        SPRING_PROFILES_ACTIVE         = "stage"
        GOOGLE_APPLICATION_CREDENTIALS = "/home/cnb/.gcreds"
      }

      resources {
        cpu    = 450
        memory = 450
      }

      config {
        image = "ghcr.io/lostcities-cloud/lostcities-matches:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}