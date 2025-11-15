#!/bin/bash

echo "📁 Iniciando preparação das pastas do ambiente..."

# Diretório base
BASE_DIR="/bskp-pro"

# Pastas de databasesbases
databases_DIRS=(
  "$BASE_DIR/databases"
)

# Pastas de dados (volumes persistentes)
DATA_DIRS=(
  "$BASE_DIR/data/grafana"
  "$BASE_DIR/data/nginx"
  "$BASE_DIR/data/glpi"
  "$BASE_DIR/data/cloudflare"
  "$BASE_DIR/data/tools"
  "$BASE_DIR/data/portainer"
)

# Pastas de backups
BACKUP_DIRS=(
  "$BASE_DIR/backups"
  "$BASE_DIR/backups/databases/grafana"
  "$BASE_DIR/backups/databases/glpi"
  "$BASE_DIR/backups/databases/zabbix"
  "$BASE_DIR/backups/data/grafana"
  "$BASE_DIR/backups/data/glpi"
  "$BASE_DIR/backups/data/zabbix"
)

# Criando diretórios
for DIR in "${DATA_DIRS[@]}" "${SERVICE_DIRS[@]}" "${BACKUP_DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    echo "📂 Criando $DIR"
    mkdir -p "$DIR"
  else
    echo "✔️ Já existe: $DIR"
  fi
done

echo "🔧 Ajustando permissões..."
chmod -R 755 "$BASE_DIR/scripts"
chmod -R 775 "$BASE_DIR/data"
chmod -R 775 "$BASE_DIR/databases"


# Configurando rede Docker personalizada
if ! docker network ls | grep -q "network-share"; then
  echo "Criando rede network-share..."
  docker network create \
    --driver=bridge \
    --subnet=172.18.0.0/16 \
    network-share
fi

echo "✅ Preparação concluída!"