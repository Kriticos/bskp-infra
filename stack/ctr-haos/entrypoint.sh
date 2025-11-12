#!/bin/bash
set -e

CONFIG_DIR="/config/custom_components/hacs"
TMP_DIR="/tmp/hacs"

# Instala o HACS no volume persistente se ainda não existir
if [ ! -d "$CONFIG_DIR" ]; then
    echo "🔧 Instalando HACS no volume persistente..."
    apk add --no-cache git
    mkdir -p /config/custom_components
    git clone --depth 1 https://github.com/hacs/integration.git "$TMP_DIR"
    mv "$TMP_DIR" /config/custom_components/hacs
    apk del git
    echo "✅ HACS instalado em $CONFIG_DIR"
else
    echo "✅ HACS já instalado — pulando instalação"
fi

# Corrige permissões (UID 1000 padrão do HA)
chown -R 1000:1000 /config/custom_components

# Inicia o Home Assistant
exec python -m homeassistant --config /config
