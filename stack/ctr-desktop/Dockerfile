FROM debian:bullseye

LABEL maintainer="Kriticos"
ENV DEBIAN_FRONTEND=noninteractive

# Instala pacotes necessários
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    cron \
    wget \
    lsb-release \
    iputils-ping \
    jq \
    iproute2 \
    ca-certificates

# Repositório do Zabbix (exemplo com versão 6.0 LTS)
RUN wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian11_all.deb && \
    dpkg -i zabbix-release_6.0-4+debian11_all.deb && \
    apt-get update && \
    apt-get install -y zabbix-sender

# Instala Speedtest oficial
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get install -y speedtest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Cria log do cron
RUN touch /var/log/cron.log

CMD ["cron", "-f"]
