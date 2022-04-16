## https://www.nomadproject.io/docs/agent/configuration/index.html

bind_addr = "0.0.0.0"

advertise {
  http = "68.49.57.165"
  rpc  = "68.49.57.165"
  serf = "68.49.57.165"
}

server {
  enabled          = true
  bootstrap_expect = 3
}

# state directory
data_dir = "/var/lib/nomad"

# binaries shouldn't go in /var/lib
plugin_dir = "/usr/lib/nomad/plugins"