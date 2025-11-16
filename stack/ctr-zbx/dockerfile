# Dockerfile para o Zabbix Server com suporte ODBC (SQL Server)
FROM zabbix/zabbix-server-mysql:ubuntu-7.4-latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Instalar pacotes ODBC e driver do SQL Server
RUN apt-get update && \
    apt-get install -y curl apt-transport-https gnupg unixodbc unixodbc-dev && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list -o /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Deixar sqlcmd no PATH
ENV PATH="$PATH:/opt/mssql-tools18/bin"

USER zabbix
