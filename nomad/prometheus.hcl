job "prometheus" {
  datacenters = ["digital-ocean"]

  update {
    max_parallel = 1
  }

  group "prometheus" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "http" {
        to = "9090"
      }

    }

    service {
      name = "prometheus"
      port = "9090"
    }

    task "web" {
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        ports = ["http"]
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--log.level=info",
        ]
        volumes = ["local/prometheus.yml:/etc/prometheus/prometheus.yml"]
      }

      resources {
        cpu    = 100
        memory = 100
      }

      template {
        data = <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 30s

scrape_configs:
  #- job_name: prometheus
  #  honor_labels: true
  #  static_configs:
  #    - targets: ["lostcities.app"]

  - job_name: gamestate-observability
    honor_labels: true
    metrics_path: /api/gamestate/actuator/prometheus
    static_configs:
      - targets: [{{ range service "gamestate" }} "{{ .Address }}:{{ .Port }}", {{ else }} {{ end }} ]

  - job_name: accounts-observability
    honor_labels: true
    metrics_path: /api/accounts/actuator/prometheus
    static_configs:
      - targets: [{{ range service "accounts" }} "{{ .Address }}:{{ .Port }}", {{ else }}  {{ end }}]

  - job_name: matches-observability
    honor_labels: true
    metrics_path: /api/matches/actuator/prometheus
    static_configs:
      - targets: [ {{ range service "matches" }} "{{ .Address }}:{{ .Port }}", {{ else }} {{ end }}]

  - job_name: player-events-observability
    honor_labels: true
    metrics_path: /api/player-events/actuator/prometheus
    static_configs:
      - targets: [ {{ range service "player-events" }} "{{ .Address }}:{{ .Port }}", {{ else }} {{ end }} ]

EOF

        destination   = "local/prometheus.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}