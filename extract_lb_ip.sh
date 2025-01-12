#!/bin/bash

# Caminho para o arquivo variables.tf
VARIABLES_FILE="terraform_openstack/variables.tf"

# Extrair o valor da variável ip_loadbalancer
LB_IP=$(grep 'variable "ip_loadbalancer"' -A 1 "$VARIABLES_FILE" | grep default | awk -F '"' '{print $2}')

# Construir e exibir a URL pública
LB_URL="http://${LB_IP}"
echo "$LB_URL"