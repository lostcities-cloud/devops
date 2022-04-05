data_dir = "/opt/consul/"
server = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP `eth0` }}"

bootstrap_expect = 3

connect {
  enabled = true
}
