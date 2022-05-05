job "loki" {
  datacenters = ["digital-ocean"]

  constraint {
    attribute = "${node.unique.name}"
    value = "lostcities-green"
  }

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "5m"
  }



  group "loki" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "loki" {
        to = 3100
      }
    }

    //volume "loki" {
    //  type      = "host"
    //  read_only = false
    //  source    = "loki"
    //}

    task "loki" {
      driver = "docker"

      service {
        name = "loki"
        port = "loki"
        check {
          name     = "Loki healthcheck"
          port     = "loki"
          type     = "http"
          path     = "/ready"
          interval = "20s"
          timeout  = "5s"
          check_restart {
            limit           = 3
            grace           = "60s"
            ignore_warnings = false
          }
        }
        tags = [

        ]
      }


      resources {
        cpu    = 512
        memory = 256
      }

      config {
        image = "grafana/loki"
        args = [
          "-config.file",
          "local/loki/local-config.yaml",
        ]

        volumes = [
          "/var/opt/loki:/loki"
        ]

        ports = ["loki"]
      }
      //volume_mount {
      //  volume      = "loki"
      //  destination = "/loki"
      //  read_only   = false
      //}
      template {
        data = <<EOH
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

EOH
        destination = "local/loki/local-config.yaml"
      }

    }
  }
}