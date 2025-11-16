#!/bin/bash

# Inicia o cron
cron

# Garante que o container não encerre
tail -f /var/log/cron.log
