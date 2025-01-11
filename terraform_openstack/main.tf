# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  user_name   = "diogo.feitosa"
  tenant_name = "admin"
  password    = "Dw18dw88@123"
  auth_url    = "http://eclipse:5000/v3/"
  region      = "RegionOne"
}

resource "openstack_compute_instance_v2" "instancias_terraform" {
  count           = 2
  name            = "instance-${count.index + 1}"
  image_id        = "dcf49c5a-0fc1-40a9-b26e-fd42c24516d6"
  flavor_id       = "cfb3f68f-ea52-4ed5-a40f-8b82befccc3f"
  key_pair        = "windows-home"
  security_groups = ["default"]
  network {
    name = "wlan"
    fixed_ip_v4 = "192.168.159.${100 + count.index}"
  }
  user_data = <<-EOT
    #!/bin/bash
    # Add Docker's official GPG key:
    apt-get update -y
    apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Add public key Ansible Server
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC79Cia51x1CXaB7l97HdWZQoZM8ALlzv4xUhzjAkdX9 jenkins@jenkins-ansible" >> /home/ubuntu/.ssh/authorized_keys

    # Criar pasta para receber aplicação
  EOT 
}