resource "openstack_compute_instance_v2" "haproxy" {
  name            = "haproxy-lb"
  image_id        = "dcf49c5a-0fc1-40a9-b26e-fd42c24516d6"  # Altere para a imagem desejada
  flavor_id       = "cfb3f68f-ea52-4ed5-a40f-8b82befccc3f"   # Altere para o tipo de máquina desejado
  key_pair        = "windows-home"
  security_groups = ["default"]
  network {
    name = "wan"
    fixed_ip_v4 = var.ip_loadbalancer
  }
  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y haproxy

    # Adiciona a configuração do HAProxy
    echo "
    frontend http_front
        bind *:80
        default_backend http_back

    backend http_back
        balance roundrobin
        server inst1 ${var.fixed_ips[0]}:80 check
        server inst2 ${var.fixed_ips[1]}:80 check

    # Painel de monitoramento
    frontend stats
        bind *:9000
        mode http
        log global
        stats enable
        stats uri /stats
        stats auth Admin:senha
    " >> /etc/haproxy/haproxy.cfg

    systemctl restart haproxy
  EOT
}
