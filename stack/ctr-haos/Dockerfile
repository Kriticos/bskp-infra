# ───────────────────────────────────────────────
# Home Assistant + HACS (instalação via git)
# ───────────────────────────────────────────────
FROM ghcr.io/home-assistant/home-assistant:stable

# Diretório de configuração
WORKDIR /config

# Instala dependências, baixa o HACS e remove pacotes temporários
RUN apk add --no-cache git \
    && mkdir -p custom_components \
    && git clone --depth 1 https://github.com/hacs/integration.git custom_components/hacs \
    && apk del git

# Define o ponto de entrada padrão
CMD [ "bash", "-c", "python -m homeassistant --config /config" ]