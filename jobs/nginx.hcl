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
        static = 8080
      }
    }

    service {
      name = "nginx"
      tags = ["default", "urlprefix-lostcities.dev/", "urlprefix-www.lostcities.dev/", "urlprefix-/ui"]
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      resources {
        cpu    = 500
        memory = 250
      }

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
          "local/frontend/package:/opt/lostcities/frontend",
        ]
      }

      artifact {
        source      = "https://github.com/lostcities-cloud/lostcities-frontend/releases/download/latest/lostcities-cloud-lostcities-frontend-0.1.0.tgz"
        destination = "local/frontend"
      }

      template {
        data = <<EOF
server {
    listen 8080;

    root  /local/frontend/package/;

    include /etc/nginx/mime.types;

    location / {
        try_files $uri /index.html;
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
