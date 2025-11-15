# MySQL Init Scripts

Esta pasta contém scripts executados automaticamente pelo MySQL **somente na primeira vez** que o container é iniciado.

## Arquivos

### 1. 01-create-databases.sql
Cria os bancos GLPI, Zabbix e Grafana.

### 2. 02-create-users.sh
Cria usuários e aplica permissões usando variáveis do `.env`.

## Como funciona
O MySQL executa tudo que estiver em `/docker-entrypoint-initdb.d` quando o volume `/var/lib/mysql` está vazio.

## Importante
- As senhas devem ser definidas no `.env` no Portainer.
- Esta pasta vai para o Git porque não contém valores sensíveis.

# Permissãos do script no host
chmod +x mysql-init/02-create-users.sh
