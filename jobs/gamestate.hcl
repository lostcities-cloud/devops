job "gamestate" {

  datacenters = ["digital-ocean"]

  group "gamestate" {
    network {
      port "service-port" { to = 8092 }
    }

    service {
      name = "gamestate"
      tags = ["default", "urlprefix-/api/gamestate"]
      port = "service-port"

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

      resources {
        cpu    = 500
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