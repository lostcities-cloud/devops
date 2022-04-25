job "player-events" {

  datacenters = ["digital-ocean"]

  group "player-events" {
    network {
      port "service-port" { to = 8093 }
    }

    service {
      name = "player-events"
      tags = ["default", "urlprefix-/api/player-events"]
      port = "service-port"

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

      resources {
        cpu    = 500
        memory = 450
      }

      config {
        image = "ghcr.io/lostcities-cloud/lostcities-player-events:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}