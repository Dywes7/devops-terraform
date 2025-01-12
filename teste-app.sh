#!/bin/bash

# Realiza a requisição GET para a aplicação no localhost:80 e captura o código de status HTTP
status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80)

# Verifica se o código de status é 200
if [ "$status_code" -eq 200 ]; then
    echo "Teste bem-sucedido! Status: $status_code"
else
    echo "Falha no teste!"
    echo "Código de saída: $status_code"
    exit 1
fi