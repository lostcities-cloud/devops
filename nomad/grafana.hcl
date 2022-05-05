job "grafana" {
  datacenters = ["digital-ocean"]

  update {
    max_parallel = 1
  }

  group "grafana" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "http" {
        to = 3000
      }
    }

    service {
      name = "grafana"
      port = "http"
    }

    task "dashboard" {
      driver = "docker"

      resources {
        cpu    = 512
        memory = 256
      }

      env {
        WORKING_DIR = "local"
      }

      config {
        ports = ["http"]
        image = "grafana/grafana:latest"


        args = [

        ]
      }

      template {
        data = <<EOF
apiVersion: 1

deleteDatasources:
  - name: Prometheus
    orgId: 1

datasources:
  - name: Prometheus
    type: prometheus
    # Access mode - proxy (server in the UI) or direct (browser in the UI).
    orgId: 1
    access: direct
    {{ range service "prometheus" }}
    url: {{ .Address }}:{{ .Port }}
    {{ else }}
    url:
    {{ end }}
    isDefault: true
    basicAuth: false
    jsonData:
      graphiteVersion: "1.1"
      tlsAuth: false
      tlsAuthWithCACert: false
    version: 1
    editable: false

EOF


        destination   = "local/provisioning/datasources/datasource.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
