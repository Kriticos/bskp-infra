#!/bin/bash

# Variáveis
data_atual=$(date +"%Y-%m-%d_%H-%M-%S")
diretorios_origem=("/bskp/srv-glpi" "/bskp/srv-grafana" "/bskp/srv-mysql" "/bskp/srv-nginx" "/bskp/srv-zbx")
diretorio_destino="/backup/data/"

# Criar backup para cada diretório
echo "Iniciando backup das pastas selecionadas..."
for origem in "${diretorios_origem[@]}"; do
    nome_pasta=$(basename "$origem")  # Ex: srv-grafana
    destino_pasta="${diretorio_destino}/${nome_pasta}"  # Ex: /backup/data/srv-grafana
    arquivo_bkp="${destino_pasta}/bkp_${nome_pasta}_${data_atual}.tar.gz"

    # Criar a pasta de destino, caso não exista
    mkdir -p "$destino_pasta"

    # Remover qualquer backup anterior
    find "$destino_pasta" -type f -name "*.tar.gz" -exec rm -f {} \;

    # Criar o novo backup
    tar -czf "$arquivo_bkp" "$origem"
    if [ $? -eq 0 ]; then
        echo "✅ Backup concluído: $arquivo_bkp"
    else
        echo "❌ Erro ao realizar o backup de $origem"
    fi
done

echo "✔️ Backup finalizado!"
