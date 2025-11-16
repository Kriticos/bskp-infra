# Projeto Zabbix com Docker Compose

Este repositório fornece um ambiente Docker Compose para provisionar os containers Zabbix Server, Frontend e Agent, todos configurados via variáveis de ambiente.

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

## Estrutura de arquivos

```plaintext
bskp/
├── scripts/                 # Scripts personalizados (se necessário)
└── ctr-zbx/                 # Projeto Zabbix
     ├── docker-compose.yml  # Definição dos serviços Docker
     ├── .env.example        # Exemplo de variáveis de ambiente
     └── README.md           # Documentação do serviço
```

## Permissões das Pastas

```bash
chown -R root:root /bskp/ctr-zbx
chmod -R 750 /bskp/ctr-zbx
```

## Arquivo **.env**

Na pasta /bskp/ctr-zbx, crie uma cópia do arquivo `.env.example` e renomeie-a para `.env`:

```bash
cp .env.example .env
```

>**OBS:** Edite o arquivo `.env` para configurar as variáveis de ambiente conforme necessário.**

## Criando a base de dados para o zabbix

Acesse o container do ctr-mysql e crie a base de dados para o zabbix:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

```sql
-- 1) Banco com charset/collation modernos
CREATE DATABASE IF NOT EXISTS zabbix
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Usuário (opção A: acessa de qualquer host)
CREATE USER IF NOT EXISTS 'zabbix'@'%' IDENTIFIED BY 'PASSWORD';

--   (opção B: se o zabbix estiver no MESMO host do MySQL)
-- CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'PASSWORD';

-- 3) Permissões mínimas necessárias no banco zabbix
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%';
-- GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';

-- 4) Em MySQL/MariaDB atuais, FLUSH PRIVILEGES é opcional (o GRANT já recarrega)
FLUSH PRIVILEGES;

-- 5) (Comando do cliente, não é SQL do servidor)
exit
```

## Subindo o serviço

Para iniciar todos os containers em segundo plano:

```bash
docker compose up -d
```

Verifique o status:

```bash
docker ps | grep zbx
```

Acompanhe os logs do Server:

```bash
docker logs -f ctr-zbx
```


## 5. Acessando o Zabbix WEB

> **OBS:** Substitua `<IP_SERVIDOR>` pelo IP do servidor onde o container está rodando e troque a porta caso tenha alterado no `.env`

```html
http://IP_SERVIDOR:4080 
```
