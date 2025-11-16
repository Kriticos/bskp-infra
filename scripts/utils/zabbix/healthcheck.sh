#!/bin/bash

# Apenas testa se tem acesso à internet (sem zabbix_sender)
TARGET="1.1.1.1"
IFACE="eth0"

if ! ip link show "$IFACE" up | grep -q "state UP"; then
  exit 1
fi

if ping -c 1 -W 2 "$TARGET" > /dev/null 2>&1; then
  exit 0
else
  exit 1
fi
