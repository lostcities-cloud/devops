job "nginx" {
  datacenters = ["digital-ocean"]

  constraint {
    attribute = "${node.unique.name}"
    value = "lostcities-yellow"
  }

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "5m"
  }

  group "nginx" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

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
      tags = ["default", "urlprefix-lostcities.dev/", "urlprefix-www.lostcities.dev/", "urlprefix-/ui"]
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
          "local:/etc/nginx/conf.d",
          "local/frontend/package:/opt/lostcities/frontend",
          "/var/opt/nginx:/var/opt/nginx"
        ]
      }

      artifact {
        source      = "https://github.com/lostcities-cloud/lostcities-frontend/releases/download/latest/lostcities-cloud-lostcities-frontend-0.1.0.tgz"
        destination = "local/frontend"
      }

      template {
        data = <<EOF

upstream accounts {
{{ range service "accounts" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream gamestate {
{{ range service "gamestate" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream player-events {
{{ range service "player-events" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream matches {
{{ range service "matches" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
    root  /local/frontend/package/;

    include /etc/nginx/mime.types;

    location /api/accounts {
        proxy_pass http://accounts;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-Host $host;
        proxy_redirect off;
        proxy_connect_timeout 90s;
        proxy_read_timeout 90s;
        proxy_send_timeout 90s;
    }

    location /api/gamestate {
        proxy_pass http://gamestate;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-Host $host;
        proxy_redirect off;
        proxy_connect_timeout 90s;
        proxy_read_timeout 90s;
        proxy_send_timeout 90s;
    }

    location /api/matches {
        proxy_pass http://matches;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-Host $host;
        proxy_redirect off;
        proxy_connect_timeout 90s;
        proxy_read_timeout 90s;
        proxy_send_timeout 90s;
    }

    location /api/player-events {
        proxy_pass http://player-events;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-Host $host;
        proxy_redirect off;
        proxy_connect_timeout 90s;
        proxy_read_timeout 90s;
        proxy_send_timeout 90s;
    }

    location / {
        try_files $uri /index.html;
        add_header Strict-Transport-Security "max-age=1000; includeSubDomains" always;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /var/opt/nginx/fullchain.pem; # managed by Certbot
    ssl_certificate_key /var/opt/nginx/privkey.pem; # managed by Certbot
    include /var/opt/nginx/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /var/opt/nginx/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = www.lostcities.dev) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = lostcities.dev) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80 ;
        listen [::]:80 ;
    server_name www.lostcities.dev lostcities.dev;
    return 404; # managed by Certbot

}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
