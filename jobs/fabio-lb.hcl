job "fabio-lb" {
  datacenters = ["digital-ocean"]

  group "fabio-lb" {

    network {
      mode = "host"
      port "ui" {
        static = 9998
      }
      port "http" {
        static = 9999
      }
    }

    service {
      name = "fabio-lb"
      port = "http"
    }

    task "fabio-lb" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 100
      }

      config {
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["ui", "http"]
        args = [
          "-registry.consul.addr", "blue.lostcities.dev:8500"
        ]

      }
    }
  }
}