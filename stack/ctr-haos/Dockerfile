# ───────────────────────────────────────────────
# Home Assistant + HACS
# Base: imagem oficial do Home Assistant
# ───────────────────────────────────────────────
FROM ghcr.io/home-assistant/home-assistant:stable

# Diretório de trabalho (configuração do HA)
WORKDIR /config

# Instala dependências básicas e baixa o HACS
RUN apk add --no-cache wget bash git \
    && wget -O - https://get.hacs.xyz | bash - \
    && apk del wget git bash

# Define o ponto de entrada padrão
CMD [ "bash", "-c", "python -m homeassistant --config /config" ]
