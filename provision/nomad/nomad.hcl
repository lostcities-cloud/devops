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
  host_volume "docker-sock" {
    path = "/var/run/docker.sock"
    read_only = true
  }

  host_volume "loki" {
    path = "/var/opt/loki"
    read_only = false
  }
}

consul {
  address = "{{ipv4_address}}:8500"
}

plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"
    volumes { enabled = true }
    # extra Docker labels to be set by Nomad on each Docker container with the appropriate value
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]
  }
}
