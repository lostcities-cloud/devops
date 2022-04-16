datacenter = "digital-ocean"
data_dir = "/opt/nomad/data"
bind_addr = "0.0.0.0"

advertise {
  http = "{{host}}"
  rpc  = "{{host}}"
  serf = "{{host}}"
}

server {
  enabled = true
  bootstrap_expect = 3
}

client {
  enabled = true
}

consul {
  address = "{{ipv4_address}}:8500"
}

plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"
    volumes { enabled = true }
  }
}