#!/bin/bash

# Carregar variáveis do arquivo .env
ENV_PATH="/bskp/scripts/backup/.env"  # Caminho absoluto ou relativo do .env

if [ -f "$ENV_PATH" ]; then
    export $(grep -v '^#' "$ENV_PATH" | xargs)

else
    echo "Arquivo .env não encontrado!"
    exit 1
fi

# Datas
DATA_ATUAL=$(date +"%Y-%m-%d_%H-%M-%S")
DATA_ULTIMO_DIA_MES=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +"%Y-%m-%d")

# Lista de bancos
BANCOS=("glpi" "grafana" "hub" "nginxproxymanager")
BASE_BACKUP="/backup/databases"

# Etapa 1: Backup .sql
echo "### ETAPA 1: Backup dos bancos ###"
for DB in "${BANCOS[@]}"; do
    PASTA="${BASE_BACKUP}/${DB}"
    ARQUIVO_SQL="${PASTA}/${DB}_backup_${DATA_ATUAL}.sql"
    mkdir -p "$PASTA"

    # Remover backups anteriores, exceto o do último dia do mês
    echo "Removendo backups antigos do banco $DB (exceto último dia do mês)..."
    find "$PASTA" -type f \( -name "*.sql" -o -name "*.sql.gz" \) ! -name "*${DATA_ULTIMO_DIA_MES}*" -exec rm -f {} \;

    echo "Backup do banco ${DB}..."
    docker exec "$CONTAINER_MYSQL" sh -c \
        "mysqldump --single-transaction --quick --no-tablespaces --routines --events --triggers -u$USER_MYSQL -p$PASSWORD_MYSQL $DB" \
        > "$ARQUIVO_SQL"

    if [ $? -eq 0 ]; then
        echo "✅ Backup gerado: $ARQUIVO_SQL"
        echo "Compactando $ARQUIVO_SQL..."
        gzip "$ARQUIVO_SQL"
    else
        echo "❌ Erro ao gerar backup do banco ${DB}"
        rm -f "$ARQUIVO_SQL"
    fi
done

echo "✔️ Backup finalizado com sucesso!"
