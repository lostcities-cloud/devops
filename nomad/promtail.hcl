job "promtail" {
  datacenters = ["dc1"]
  type        = "service"

  group "promtail" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "promtail" {
      driver = "docker"

      config {
        image = "grafana/promtail:master"

        args = [
          "-config.file",
          "local/config.yaml",
        ]

        port_map {
          promtail_port = 3000
        }
      }

      template {
        data = <<EOH
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

client:
  url: http://10.70.103.139:22503/api/prom/push

scrape_configs:
- job_name: system
  entry_parser: raw
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /alloc/logs/*
EOH

        destination = "local/config.yaml"
      }

      resources {
        cpu    = 50
        memory = 32

        network {
          mbits = 1
          port  "promtail_port"{}
        }
      }

      service {
        name = "promtail"
        port = "promtail_port"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}