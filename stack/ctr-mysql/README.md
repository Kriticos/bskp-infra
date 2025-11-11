# Projeto MySQL com Docker Compose

Este repositório fornece um ambiente Docker Compose para provisionar um container MySQL com configuração personalizada via variáveis de ambiente.

## Pré-requisitos

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- Rede Docker `network-share` já criada:

## Criar a rede externa se ainda não existir

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
```

> **OBS:**  Ajuste a subnet conforme a necessidade do seu cenário.

## Estrutura de arquivos

```plaintext
bskp/
├── databases/               # Diretório principal do container MySQL
└── ctr-mysql/               # Projeto MySQL
     ├── docker-compose.yml  # Definição dos serviços Docker
     ├── .env.example        # Exemplo de variáveis de ambiente
     └── README.md           # Documentação do serviço
```

## 1. Arquivo **.env**

Na pasta /bskp/ctr-glpi, crie uma cópia do arquivo `.env.example` e renomeie-a para `.env`:

```bash
cp .env.example .env
```

>**OBS:** Edite o arquivo `.env` para configurar as variáveis de ambiente conforme necessário.**

## 2. Subindo o serviço

Para iniciar o container em segundo plano:

```bash
# Acessar pasta do container
cd /bskp/ctr-mysql

# Inciciar o container
docker compose up -d
```

Verifique se o container está em execução:

```bash
docker ps | grep ctr-mysql
```

Acompanhe os logs:

```bash
docker logs -f ctr-mysql
```

## 3. Restaurando uma base de dados

### 3.1 Para o container

```bash
# Acessar pasta do container
cd /bskp/ctr-glpi

# Parar o container
docker compose stop
```

### 3.2 Copiando a base de dados para o servidor

Copie a base de dados **.sql** para a pasta **/tmp** do servidor onde o container está hospedado.

### 3.3 Copiando a base de dados para o container mysql

No servidor docker:

- Copiar o backup da base de dados para o container

```bash
docker cp /tmp/NOME_DO_BACKUP.sql ctr-mysql:/tmp/NOME_DO_BACKUP.sql
```

### 3.4  Restaurar o backup dentro do container

Acesse o container

```bash
docker exec -it ctr-mysql bash
```

```bash
mysql -u root -p
```

Verifique se o banco de dados existe

```bash
SHOW DATABASES;
```

Se não existir, crie o banco de dados

```bash
mysql -u root -p'SENHA_DO_ROOT'
```

```sql
CREATE DATABASE IF NOT EXISTS nome_do_banco;
```

Restaure o backup

```bash
mysql -u root -p'SENHA_DO_ROOT' nome_da_base_de_dados < /tmp/NOME_DO_BACKUP.sql
```
