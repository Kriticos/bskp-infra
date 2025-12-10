###############################################################
# STAGE 1 - BUILDER (instala Ansible + WinRM)
###############################################################
FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Dependências mínimas para build
RUN apt update && apt install -y \
        python3 python3-pip python3-venv \
        curl gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Criar ambiente virtual Python + libs necessárias
RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install \
        ansible \
        pywinrm \
        requests-ntlm

###############################################################
# STAGE 2 - FINAL IMAGE (ultra minimalista)
###############################################################
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Dependências runtime mínimas
RUN apt update && apt install -y \
        python3 python3-pip python3-venv \
        ca-certificates \
        curl \
        nano \
    && rm -rf /var/lib/apt/lists/*

# Copiar ambiente virtual com Ansible + WinRM
COPY --from=builder /venv /venv

# Criar usuário não-root
RUN useradd -m -s /bin/bash ansible && \
    mkdir -p /playbooks && chown -R ansible:ansible /playbooks

# Editor padrão para o Ansible Vault
ENV ANSIBLE_EDITOR=nano

# PATH ajustado
ENV PATH="/venv/bin:${PATH}"

WORKDIR /playbooks
USER ansible

CMD ["/bin/bash"]
