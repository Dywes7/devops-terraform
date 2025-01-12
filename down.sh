#!/bin/bash

# Parar e remover containers
docker compose down

# Remover imagens associadas se elas existirem
if docker image inspect vicio/app:TAG > /dev/null 2>&1; then
  docker rmi vicio/app:TAG
else
  echo "Imagem vicio/app:TAG não encontrada. Pulando remoção de imagem."
fi

exit 0