FROM debian:bookworm

LABEL maintainer="Kriticos"
ENV DEBIAN_FRONTEND=noninteractive

# Pacotes essenciais + speedtest
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
    apt clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Instala Speedtest CLI (oficial da Ookla)
# -------------------------------------------------------------------
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install -y speedtest && \
    apt clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Instala Zabbix Sender (versão 7.2 estável, compatível com Bookworm)
# -------------------------------------------------------------------
RUN wget https://repo.zabbix.com/zabbix/7.2/stable/debian/pool/main/z/zabbix/zabbix-sender_7.2.9-1%2Bdebian12_amd64.deb && \
    dpkg -i zabbix-release_7.2-1+debian12_all.deb && \
    apt update && apt install -y zabbix-sender && \
    rm -f zabbix-release_7.2-1+debian12_all.deb && \
    apt clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------
# Configuração de logs e scripts
# -------------------------------------------------------------------
RUN touch /var/log/cron.log

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]