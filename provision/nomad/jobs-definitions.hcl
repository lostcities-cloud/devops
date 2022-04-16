job "accounts" {

  datacenters = ["digital-ocean"]

  group "accounts" {
    network {
      port "service-port" { to = 8090 }
    }

    service {
      name = "accounts"
      port = "service-port"
      tags = ["default", "urlprefix-/api/accounts"]

      check {
        type = "http"
        path = "/api/accounts/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "accounts" {
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
        image = "ghcr.io/lostcities-cloud/lostcities-accounts:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}

job "matches" {

  datacenters = ["digital-ocean"]

  group "matches" {
    network {
      port "service-port" {
        to = 8091
      }
    }

    service {
      name = "matches"
      tags = ["default", "urlprefix-/api/matches"]
      port = "service-port"
      check {
        type = "http"
        path = "/api/matches/actuator/health"
        interval = "30s"
        timeout  = "2s"
      }
    }

    task "matches" {
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
        image = "ghcr.io/lostcities-cloud/lostcities-matches:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}

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
        memory = 450
      }

      config {
        image = "ghcr.io/lostcities-cloud/lostcities-gamestate:latest"

        volumes = ["/usr/share/.gcreds:/home/cnb/.gcreds"]
        ports = ["service-port"]
      }
    }
  }
}

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
      name: "fabio-lb"
      port: "http"
    }

    task "fabio-lb" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 100
      }

      config {
        image = "fabiolb/fabio"

        ports = ["ui", "http"]
        args = [
          "-registry.consul.addr", "143.198.120.219:8500"
        ]

      }
    }
  }
}

job "nginx" {
  datacenters = ["digital-ocean"]

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "nginx"
      port = "http"
    }




    task "nginx" {
      driver = "docker"

      resources {
        cpu    = 150
        memory = 200
      }

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
          "local/frontend:/opt/lostcities/frontend/package"
        ]
      }

      artifact {
        source      = "https://github.com/lostcities-cloud/lostcities-frontend/releases/download/latest/lostcities-cloud-lostcities-frontend-0.1.0.tgz"
        destination = "local/frontend"
      }

      template {
        data = <<EOF
upstream fabio-lb {
{{ range service "fabio-lb" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
    listen 8080;

    root /opt/lostcities/frontend/;

    include /etc/nginx/mime.types;

    location / {
        try_files $uri /index.html;
    }

    location /api {
        proxy_pass http://fabio-lb;
    }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
