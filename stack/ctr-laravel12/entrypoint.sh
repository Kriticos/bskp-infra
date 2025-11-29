#!/bin/bash
set -euo pipefail

APP_DIR="${WORKDIR:-/var/www/html}"
MYSQL_DATADIR="/var/lib/mysql"
MYSQL_SOCKET="/run/mysqld/mysqld.sock"
LARAVEL_VERSION="${LARAVEL_VERSION:-12.*}"
APP_PORT="${APP_PORT:-8000}"

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
MYSQL_DATABASE="${MYSQL_DATABASE:-laravel}"
MYSQL_USER="${MYSQL_USER:-laravel}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-secret}"
MYSQL_PORT="${MYSQL_PORT:-3306}"

APP_PID=""
MYSQL_PID=""
SHUTDOWN_TRIGGERED=0

wait_for_mysql() {
  local auth_opts=("$@")
  for _ in $(seq 1 30); do
    if mysqladmin "${auth_opts[@]}" ping >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "[entrypoint] MySQL não inicializou a tempo" >&2
  exit 1
}

bootstrap_mysql() {
  mkdir -p "${MYSQL_DATADIR}" /run/mysqld "$(dirname "${MYSQL_SOCKET}")"
  chown -R mysql:mysql "${MYSQL_DATADIR}" /run/mysqld

  if [ ! -d "${MYSQL_DATADIR}/mysql" ]; then
    echo "[entrypoint] Inicializando datadir do MySQL/MariaDB"
    init_cmd="$(command -v mariadb-install-db || command -v mysql_install_db)"
    if [ -z "${init_cmd}" ]; then
      echo "[entrypoint] Não encontrei mariadb-install-db/mysql_install_db" >&2
      exit 1
    fi
    "${init_cmd}" \
      --datadir="${MYSQL_DATADIR}" \
      --user=mysql \
      --skip-test-db \
      --auth-root-authentication-method=normal

    mysqld_safe --datadir="${MYSQL_DATADIR}" --user=mysql --skip-networking &
    local temp_pid=$!
    wait_for_mysql --protocol=socket -uroot
    mysql --protocol=socket -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
    mysqladmin --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown || true
    wait "${temp_pid}"
  fi
}

start_mysql() {
  echo "[entrypoint] Iniciando MySQL"
  mysqld_safe --datadir="${MYSQL_DATADIR}" --user=mysql --socket="${MYSQL_SOCKET}" --port="${MYSQL_PORT}" &
  MYSQL_PID=$!
  wait_for_mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}"
}

prepare_laravel() {
  mkdir -p "${APP_DIR}"
  if [ ! -f "${APP_DIR}/artisan" ]; then
    echo "[entrypoint] Criando projeto Laravel (${LARAVEL_VERSION})"
    composer create-project --no-interaction --prefer-dist laravel/laravel "${APP_DIR}" "${LARAVEL_VERSION}"
  fi

  cd "${APP_DIR}"

  if ! composer show jeroennoten/laravel-adminlte >/dev/null 2>&1; then
    echo "[entrypoint] Instalando AdminLTE"
    composer require --no-interaction jeroennoten/laravel-adminlte
    php artisan adminlte:install --force
    php artisan adminlte:publish --force
  fi

  if [ ! -f .env ]; then
    echo "[entrypoint] Gerando arquivo .env"
    cp .env.example .env
    sed -i "s|^APP_URL=.*|APP_URL=${APP_URL:-http://localhost:${APP_PORT}}|" .env
    sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
    sed -i "s|^DB_HOST=.*|DB_HOST=127.0.0.1|" .env
    sed -i "s|^DB_PORT=.*|DB_PORT=${MYSQL_PORT}|" .env
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${MYSQL_DATABASE}|" .env
    sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${MYSQL_USER}|" .env
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${MYSQL_PASSWORD}|" .env
    php artisan key:generate --force
  fi

  php artisan config:clear >/dev/null 2>&1 || true
  php artisan cache:clear >/dev/null 2>&1 || true
  chown -R www-data:www-data storage bootstrap/cache || true
}

start_app() {
  cd "${APP_DIR}"
  if [ $# -eq 0 ]; then
    set -- php artisan serve --host=0.0.0.0 --port "${APP_PORT}"
  fi
  echo "[entrypoint] Iniciando aplicação Laravel em porta ${APP_PORT}"
  "$@" &
  APP_PID=$!
  wait "${APP_PID}"
}

shutdown() {
  if [[ "${SHUTDOWN_TRIGGERED}" -eq 1 ]]; then
    return
  fi
  SHUTDOWN_TRIGGERED=1
  echo "[entrypoint] Encerrando serviços"
  if [[ -n "${APP_PID:-}" ]] && kill -0 "${APP_PID:-0}" >/dev/null 2>&1; then
    kill "${APP_PID}" >/dev/null 2>&1 || true
  fi
  if [[ -n "${MYSQL_PID:-}" ]] && kill -0 "${MYSQL_PID:-0}" >/dev/null 2>&1; then
    mysqladmin --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown >/dev/null 2>&1 || kill "${MYSQL_PID}" >/dev/null 2>&1 || true
  fi
}

trap shutdown TERM INT EXIT

bootstrap_mysql
start_mysql
prepare_laravel
start_app "$@"
