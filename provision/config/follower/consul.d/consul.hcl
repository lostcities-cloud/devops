data_dir = "/opt/consul/"
server = true
ui_config = true
client_addr = "0.0.0.0"
bind_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP `eth0` }}"

connect {
  enabled = true
}

retry_join_wan = ["159.223.175.31"]
