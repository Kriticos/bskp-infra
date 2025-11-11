#!/bin/bash

# Configurações
ZABBIX_SERVER="192.168.0.20"
HOST="Link - Fasternet"

# Executa speedtest e salva em JSON
RESULT=$(speedtest --accept-license --accept-gdpr -f json)

# Valida se houve retorno
if [ -z "$RESULT" ]; then
  echo "Erro: resultado do speedtest vazio."
  exit 1
fi

# Extrai métricas com proteção
DOWNLOAD_BITS=$(echo "$RESULT" | jq '.download.bandwidth // 0')
UPLOAD_BITS=$(echo "$RESULT"   | jq '.upload.bandwidth // 0')
PING_LATENCY=$(echo "$RESULT" | jq '.ping.latency // 0')
PING_JITTER=$(echo "$RESULT"  | jq '.ping.jitter // 0')
PACKET_LOSS=$(echo "$RESULT"  | jq '.packetLoss // 0')
DOWNLOAD_LATENCY=$(echo "$RESULT" | jq '.download.latency.iqm // 0')
UPLOAD_LATENCY=$(echo "$RESULT"   | jq '.upload.latency.iqm // 0')
RESULT_URL=$(echo "$RESULT"   | jq -r '.result.url // "N/A"')
SERVER_NAME=$(echo "$RESULT" | jq -r '.server.name // "N/A"')
SERVER_LOCATION=$(echo "$RESULT" | jq -r '.server.location // "N/A"')

# Converte para Mbps
DOWNLOAD_MBPS=$(awk "BEGIN {printf \"%.2f\", $DOWNLOAD_BITS * 8 / 1000000}")
UPLOAD_MBPS=$(awk "BEGIN {printf \"%.2f\", $UPLOAD_BITS * 8 / 1000000}")

# Diagnóstico visual
echo "[DEBUG] ========== SPEEDTEST DIAGNÓSTICO =========="
echo "[DEBUG] DOWNLOAD_BITS     : $DOWNLOAD_BITS"
echo "[DEBUG] DOWNLOAD_MBPS     : $DOWNLOAD_MBPS"
echo "[DEBUG] UPLOAD_BITS       : $UPLOAD_BITS"
echo "[DEBUG] UPLOAD_MBPS       : $UPLOAD_MBPS"
echo "[DEBUG] PING_LATENCY      : $PING_LATENCY"
echo "[DEBUG] PING_JITTER       : $PING_JITTER"
echo "[DEBUG] PACKET_LOSS       : $PACKET_LOSS"
echo "[DEBUG] DOWNLOAD_LATENCY  : $DOWNLOAD_LATENCY"
echo "[DEBUG] UPLOAD_LATENCY    : $UPLOAD_LATENCY"
echo "[DEBUG] SERVER_NAME       : $SERVER_NAME"
echo "[DEBUG] SERVER_LOCATION   : $SERVER_LOCATION"
echo "[DEBUG] RESULT_URL        : $RESULT_URL"
echo "[DEBUG] ============================================="

# Envia para Zabbix
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.download          -o "$DOWNLOAD_MBPS"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.upload            -o "$UPLOAD_MBPS"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.latency_jitter    -o "$PING_JITTER"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.packet_loss       -o "$PACKET_LOSS"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.download_ping     -o "$DOWNLOAD_LATENCY"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.upload_ping       -o "$UPLOAD_LATENCY"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.server_name       -o "$SERVER_NAME"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.server_location   -o "$SERVER_LOCATION"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.result_url        -o "$RESULT_URL"
zabbix_sender -z $ZABBIX_SERVER -s "$HOST" -k speedtest.ping              -o "$PING_LATENCY"