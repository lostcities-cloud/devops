group "grafana" {
  network {
    mode ="bridge"
    port "http" {
      static = 3000
      to     = 3000
    }
  }

  service {
    name = "grafana"
    port = "3000"

    connect {
      sidecar_service {
        proxy {
          upstreams {
            destination_name = "prometheus"
            local_bind_port  = 9090
          }
        }
      }
    }
  }

  task "dashboard" {
    driver = "docker"
    config {
      image = "grafana/grafana:7.0.0"
    }
  }
}