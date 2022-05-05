job "player-events" {
  datacenters = ["digital-ocean"]

  update {
    max_parallel = 2
  }

  group "player-events" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "service-port" { to = 8093 }
    }

    service {
      name = "player-events"
      port = "service-port"
      tags = ["urlprefix-/api/player-events"]

      check {
        type = "http"
        path = "/api/player-events/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "player-events" {
      driver = "docker"

      env {
        SECRET_MANAGER                 = "true"
        SPRING_PROFILES_ACTIVE         = "stage"
        GOOGLE_APPLICATION_CREDENTIALS = "/home/cnb/.gcreds"
      }

      logs {
        max_files = 10
        max_file_size = 10
      }

      resources {
        cpu = 500
        memory = 500
      }

      config {
        image = "ghcr.io/lostcities-cloud/lostcities-player-events:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}