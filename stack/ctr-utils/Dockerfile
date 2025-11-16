FROM debian:bookworm
LABEL maintainer="Kriticos"

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------------
# Pacotes essenciais + speedtest
# -------------------------------------------------------------------
RUN apt update && apt install -y \
    jq \
    gnupg \
    curl \
    wget \
    rsync \
    cron \
    bash \
    unzip \
    nano \
    zip \
    iproute2 \
    dnsutils \
    iputils-ping \
    lsb-release \
    ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Instala Speedtest CLI (oficial da Ookla)
# -------------------------------------------------------------------
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install -y speedtest && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Instala Zabbix Sender diretamente (versão 7.2.9)
# -------------------------------------------------------------------
RUN set -eux; \
    wget -q https://repo.zabbix.com/zabbix/7.2/stable/debian/pool/main/z/zabbix/zabbix-sender_7.2.9-1+debian12_amd64.deb; \
    apt install -y ./zabbix-sender_7.2.9-1+debian12_amd64.deb; \
    rm -f zabbix-sender_7.2.9-1+debian12_amd64.deb; \
    apt clean; \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Garantir log do cron existir mesmo após volumes
# -------------------------------------------------------------------
CMD ["bash", "-c", "touch /var/log/cron.log && cron && tail -f /var/log/cron.log"]

# -------------------------------------------------------------------
# EntryPoint externo (mapeado via volume)
# -------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/scripts/utils/entrypoint.sh"]
