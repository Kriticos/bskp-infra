# Projeto GLPI com Docker Compose

Este projeto tem como objetivo facilitar a implementação do GLPI (Gestionnaire Libre de Parc Informatique) utilizando o Docker e o Docker Compose.

## Pré-requisitos

Antes de começar, verifique se você tem os seguintes itens instalados:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- Rede Docker `network-share` já criada:
- Container [ctr-mysql](https://github.com/Kriticos/ctr-mysql) rodando

## Criar a rede externa se ainda não existir

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
```

> **OBS:**  Ajuste a subnet conforme a necessidade do seu cenário.

## Estrutura do Projeto

A estrutura do projeto é a seguinte:

```bash
bskp/
  └── ctr-glpi/
      ├── .env
      ├── .env.example
      ├── docker-compose.yml
      └── cron/
            └── crontab
```

## Configuração

### 1. Clononando o repositório

Crie a pasta **bskp** e acesse-a:

Depois execute:

```bash
git clone https://github.com/Kriticos/ctr-glpi.git ctr-glpi
cd ctr-glpi
```

## 2. Criando a base de dados para o GLPI

Acesse o container do ctr-mysql e crie a base de dados para o glpi:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

```sql
-- 1) Banco com charset/collation modernos
CREATE DATABASE IF NOT EXISTS glpi
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Usuário (opção A: acessa de qualquer host)
CREATE USER IF NOT EXISTS 'glpi'@'%' IDENTIFIED BY 'PASSWORD';

--   (opção B: se o GLPI estiver no MESMO host do MySQL)
-- CREATE USER IF NOT EXISTS 'glpi'@'localhost' IDENTIFIED BY 'PASSWORD';

-- 3) Permissões mínimas necessárias no banco glpi
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'%';
-- GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';

-- 4) Em MySQL/MariaDB atuais, FLUSH PRIVILEGES é opcional (o GRANT já recarrega)
FLUSH PRIVILEGES;

-- 5) (Comando do cliente, não é SQL do servidor)
exit
```

## 3. Arquivo **.env**

Na pasta /bskp/ctr-glpi, crie uma cópia do arquivo `.env.example` e renomeie-a para `.env`:

```bash
cp .env.example .env
```

>**OBS:** Edite o arquivo `.env` para configurar as variáveis de ambiente conforme necessário.**

## 4. Iniciando o container

Para iniciar todos os containers em segundo plano:

```bash
docker compose up -d
```

Verifique o status:

```bash
docker ps | grep glpi
```

Acompanhe os logs do Server:

```bash
docker logs -f ctr-glpi
```

Isso iniciará os contêineres em segundo plano.

## 5. Acessando o glpi WEB

> **OBS:** Substitua `<IP_SERVIDOR>` pelo IP do servidor onde o container está rodando e troque a porta caso tenha alterado no `.env`

```html
http://IP_SERVIDOR:7080 
```

## 6. Restaurando o backup do glpi

### 6.1 Para o container do GLPI

```bash
# Acessar pasta do container
cd /bskp/ctr-glpi

# Parar o container
docker compose stop
```

### 6.2 Copiando o arquivo para dentro do container

- Copie o arquivo **.sql** para a pasta **/tmp** do servidor

- Depois de copiar o arquivo **.sql** para a pasta **/tmp** do servidor, copie o arquivo para dentro do container ctr-mysql

```bash
docker cp /tmp/NOME_DO_BKP.sql ctr-mysql:/tmp/
```

### 6.3 Restaurando o banco de dados

- Acesse o conteiner ctr-mysql

```bash
docker exec -it ctr-mysql bash
```

- Restaure a base de dados

```bash
mysql -u glpi -p glpi < /tmp/NOME_DO_BKP.sql
```

- Digite a senha do usuario glpi do banco de dados e aguarde o processo terminar

- Após terminar saia do container

```bash
exit
```

- Inicie o container novamente

```bash
# Acessar pasta do container
cd /bskp/ctr-glpi

# Subir o container
docker compose up -d
```
