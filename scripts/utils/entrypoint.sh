#!/bin/bash

echo "[INFO] Iniciando ctr-utils..."

# Garantir permissões (se necessário)
chmod -R 755 /usr/local/bin/scripts

# Iniciar cron
service cron start

# Exibir log em tempo real
tail -f /var/log/cron.log
