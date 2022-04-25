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