datacenter = "digital-ocean"
node_name = "{{box}}"
data_dir = "/opt/consul"
//encrypt = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
//verify_incoming = true
//verify_outgoing = true
//verify_server_hostname = true
server = true


bind_addr = "{{ipv4_address}}"
client_addr = "0.0.0.0"

performance {
  raft_multiplier = 1
}

domain = "{{ domain }}"
recursors = [
  "dns1.registrar-servers.com",
  "dns2.registrar-servers.com"
]

{% if box == 'blue' %}
bootstrap_expect = 3

ui_config {
  enabled = true
  content_path = "/consul/ui"
}
{% else %}
retry_join_wan = ["{{nomad_join}}"]
{% endif %}

