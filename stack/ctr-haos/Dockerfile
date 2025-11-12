# ───────────────────────────────────────────────
# Home Assistant + HACS com persistência
# ───────────────────────────────────────────────
FROM ghcr.io/home-assistant/home-assistant:stable

# Copia o entrypoint personalizado
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define o diretório de trabalho
WORKDIR /config

# Usa o entrypoint customizado
ENTRYPOINT ["/entrypoint.sh"]
