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
    }

    service {
      name = "fabio-lb-proxy"
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
          "-registry.consul.addr", "157.230.176.42:8500"
        ]
      }
    }
  }
}