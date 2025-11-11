#!/bin/bash 
 
ZABBIX_SERVER="172.18.0.30" 
ZABBIX_HOST="Link - Fasternet" 
ZABBIX_KEY="check.connectivity.level" 
 
# IP público para teste (Cloudflare DNS) 
TARGET="1.1.1.1" 
 
# Verifica se interface de rede principal está ativa (ajuste se necessário) 
IFACE="eth0" 
if ! ip link show "$IFACE" up | grep -q "state UP"; then 
  VALUE=2  # LAN down 
  MSG="LAN down (interface $IFACE não está UP)"
else 
  if ping -c 1 -W 2 "$TARGET" > /dev/null 2>&1; then 
    VALUE=0  # Internet OK 
    MSG="Conectado à internet"
  else 
    VALUE=1  # Sem Internet 
    MSG="Sem acesso à internet (ping para $TARGET falhou)"
  fi 
fi 
 
# Exibe o resultado no terminal
echo "[CHECK] Status de conectividade: $MSG (código: $VALUE)"

# Envia para o Zabbix 
zabbix_sender -z "$ZABBIX_SERVER" -s "$ZABBIX_HOST" -k "$ZABBIX_KEY" -o "$VALUE" 