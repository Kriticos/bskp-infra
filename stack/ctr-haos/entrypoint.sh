#!/bin/bash
set -e

CONFIG_DIR="/config"
HACS_DIR="$CONFIG_DIR/custom_components/hacs"
TMP_HACS="/tmp/hacs"

install_or_update_hacs() {
    echo "🔎 Verificando HACS..."
    apk add --no-cache git > /dev/null

    if [ ! -d "$HACS_DIR" ]; then
        echo "📦 Instalando HACS (primeira vez)..."
        mkdir -p "$CONFIG_DIR/custom_components"
        git clone --depth 1 https://github.com/hacs/integration.git "$TMP_HACS"
        cp -r "$TMP_HACS/custom_components/hacs" "$CONFIG_DIR/custom_components/"
        rm -rf "$TMP_HACS"
        echo "✅ HACS instalado com sucesso!"
    else
        echo "🔄 Atualizando HACS..."
        git -C "$HACS_DIR" pull --ff-only || true
        echo "✅ HACS atualizado (ou já estava na última versão)"
    fi

    # Corrige permissões
    chown -R 1000:1000 "$CONFIG_DIR/custom_components"
    chmod -R 755 "$CONFIG_DIR/custom_components"

    apk del git > /dev/null
}

# Executa a função de instalação/atualização
install_or_update_hacs

# Inicia o Home Assistan
