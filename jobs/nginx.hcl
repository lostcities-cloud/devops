job "nginx" {
  datacenters = ["digital-ocean"]

  constraint {
    attribute = "${node.unique.name}"
    value = "lostcities-yellow"
  }

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 80
      }

      port "https" {
        static = 443
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    service {
      name = "nginx-secure"
      port = "https"
    }

    task "nginx" {
      driver = "docker"

      resources {
        cpu    = 500
        memory = 250
      }

      config {
        image = "nginx"

        ports = ["http", "https"]

        volumes = [
          //"local:/etc/nginx/conf.d",
          "local/frontend/package:/opt/lostcities/frontend",
          "local/certs:/etc/nginx/certs"
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
    listen 443 ssl;
    listen 80;

    ssl_certificate /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

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
