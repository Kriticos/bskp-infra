FROM ghcr.io/home-assistant/home-assistant:stable

# Copia o entrypoint automatizado
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]
