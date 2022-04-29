job "gamestate" {
  datacenters = ["digital-ocean"]

  group "gamestate" {
    network {
      port "service-port" { to = 8092 }
    }

    service {
      name = "gamestate"
      port = "service-port"
      tags = ["urlprefix-/api/gamestate"]

      check {
        type = "http"
        path = "/api/gamestate/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "gamestate" {
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
        image = "ghcr.io/lostcities-cloud/lostcities-gamestate:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}