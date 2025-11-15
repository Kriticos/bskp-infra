#!/bin/bash

echo "[mysql-init] Criando usuários e permissões..."

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF

-- Usuário GLPI
CREATE USER IF NOT EXISTS '${USER_GLPI}'@'%' IDENTIFIED BY '${PASS_GLPI}';
GRANT ALL PRIVILEGES ON glpi.* TO '${USER_GLPI}'@'%';

-- Usuário Zabbix
CREATE USER IF NOT EXISTS '${USER_ZABBIX}'@'%' IDENTIFIED BY '${PASS_ZABBIX}';
GRANT ALL PRIVILEGES ON zabbix.* TO '${USER_ZABBIX}'@'%';

-- Usuário Grafana
CREATE USER IF NOT EXISTS '${USER_GRAFANA}'@'%' IDENTIFIED BY '${PASS_GRAFANA}';
GRANT ALL PRIVILEGES ON grafana.* TO '${USER_GRAFANA}'@'%';

FLUSH PRIVILEGES;
EOF

echo "[mysql-init] Finalizado!"
