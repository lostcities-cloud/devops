job "fabio-lb" {
  datacenters = ["digital-ocean"]

  constraint {
    attribute = "${node.unique.name}"
    value = "lostcities-red"
  }


  group "fabio-lb" {

    network {
      port "ui" {
        static = 9998
      }
      port "http" {
        static = 9999
      }
    }

    service {
      name = "fabio-lb-ui"
      port = "ui"

      check {
        type = "http"
        path = "/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    service {
      name = "fabio-lb"
      port = "http"
    }

    task "fabio-lb" {
      driver = "docker"

      resources {
        cpu    = 300
        memory = 300
      }

      config {
        image = "fabiolb/fabio"
        ports = ["ui", "http"]
        args = [
          "-registry.consul.addr", "red.lostcities.dev:8500"
        ]
      }
    }
  }
}