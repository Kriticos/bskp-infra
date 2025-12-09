FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------
# Instalar dependências base do sistema
# ---------------------------------------------------------------
RUN apt update && \
    apt install -y \
        curl \
        gnupg \
        python3 \
        python3-pip \
        python3-dev \
        gcc \
        g++ \
        make \
        unixodbc \
        unixodbc-dev \
        krb5-user \
        libkrb5-dev \
        libkrb5-3 \
        sshpass \
        nano \
        iputils-ping \
        git && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Repositório Microsoft para ODBC Driver 18 – Método correto
# ---------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y curl apt-transport-https gnupg unixodbc unixodbc-dev && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list -o /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# ---------------------------------------------------------------
# Instalar Python libs: pyodbc + WinRM + Ansible
# ---------------------------------------------------------------
RUN pip3 install --upgrade pip --break-system-packages && \
    pip3 install --break-system-packages \
        pyodbc \
        ansible \
        pywinrm \
        pywinrm[credssp] \
        requests-ntlm \
        requests-kerberos \
        pykerberos

# ---------------------------------------------------------------
# Instalar coleções do Ansible
# ---------------------------------------------------------------
RUN ansible-galaxy collection install \
        ansible.windows \
        community.windows \
        community.general

# ---------------------------------------------------------------
# Diretório padrão para playbooks
# ---------------------------------------------------------------
WORKDIR /playbooks

# ---------------------------------------------------------------
# Entrar sempre no bash
# ---------------------------------------------------------------
CMD ["/bin/bash"]
