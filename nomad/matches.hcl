job "matches" {

  datacenters = ["digital-ocean"]

  update {
    max_parallel = 2
  }

  group "matches" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "service-port" {
        to = 8091
      }
    }

    service {
      name = "matches"
      tags = ["urlprefix-/api/matches"]
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
        cpu    = 500
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