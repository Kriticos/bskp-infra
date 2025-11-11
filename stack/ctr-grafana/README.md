# Projeto Grafana com Docker Compose

Este repositório fornece um ambiente Docker Compose para executar o Grafana, configurado via variáveis de ambiente.  

## Pré-requisitos

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- Rede Docker `network-share` já criada:
- Container [ctr-mysql](https://github.com/Kriticos/ctr-mysql) rodando

```bash
docker network create --driver bridge network-share --subnet=<SUBNET>
```

## Criar a rede externa se ainda não existir

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
```

> **OBS:**  Ajuste a subnet conforme a necessidade do seu cenário.

```plaintext
bskp/
└── ctr-grafana              # Projeto Grafana
     ├── config              # Dados persistentes do Grafana
     |     ├──grafana.ini    # Configuração do Grafana
     |     └──ldap.toml      # Configuração do LDAP
     ├── data                # Configurações personalizadas do Grafana
     ├── maps                # Arquivos geojson
     ├── docker-compose.yml  # Definição dos serviços Docker
     ├── .env.example        # Exemplo de variáveis de ambiente
     ├── Dockerfile          # Dockerfile
     └── README.md           # Documentação do serviço
```

## 1. Permissões das Pastas

```bash
chown -R 472:472 config data maps
chmod -R 755 config data maps
```

## 2. Arquivo **.env**

Na pasta /bskp/ctr-grafana, crie uma cópia do arquivo `.env.example` e renomeie-a para `.env`:

```bash
cp .env.example .env
```

## 3. Criando a base de dados

Acesse o container do ctr-mysql e crie a base de dados para o Grafana:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

## 4. Criando a base de dados para o grafana

Acesse o container do ctr-mysql e crie a base de dados para o grafana:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

```sql
-- 1) Banco com charset/collation modernos
CREATE DATABASE IF NOT EXISTS grafana
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Usuário (opção A: acessa de qualquer host)
CREATE USER IF NOT EXISTS 'grafana'@'%' IDENTIFIED BY 'PASSWORD';

--   (opção B: se o grafana estiver no MESMO host do MySQL)
-- CREATE USER IF NOT EXISTS 'grafana'@'localhost' IDENTIFIED BY 'PASSWORD';

-- 3) Permissões mínimas necessárias no banco grafana
GRANT ALL PRIVILEGES ON grafana.* TO 'grafana'@'%';
-- GRANT ALL PRIVILEGES ON grafana.* TO 'grafana'@'localhost';

-- 4) Em MySQL/MariaDB atuais, FLUSH PRIVILEGES é opcional (o GRANT já recarrega)
FLUSH PRIVILEGES;

exit
```

> **OBS:** Substitua `PASSWORD` pela senha desejada e ajuste o host conforme a necessidade do seu cenário.

## 5. Subindo o serviço

Para iniciar todos os containers em segundo plano:

```bash
# Acessar pasta do container
cd /bskp/ctr-grafana

# Iniciar o container
docker compose up -d
```

Verifique o status:

```bash
docker ps | grep ctr-grafana
```

Acompanhe os logs do Server:

```bash
docker logs -f ctr-grafana
```

Qualquer dúvida ou sugestão, abra uma issue ou envie uma contribuição!

## 6. Após subir o grafana pela primeira vez

- Copie os arquivos grafana.ini e ldap.toml para a pasta config

```bash
docker cp ctr-grafana:/etc/grafana/grafana.ini /bskp/ctr-grafana/config/grafana.ini

docker cp ctr-grafana:/etc/grafana/ldap.toml /bskp/ctr-grafana/config/ldap.toml
```

- Atualizar as permissões da pasta config

```bash
chown -R 472:472 /bskp/ctr-grafana/config
chmod -R 640 /bskp/ctr-grafana/config/*
```

- Parar o container

```bash
docker compose stop
```

- Ajustar docker-composeyml

Descomente a linha 23 do arquivo docker-compose.yml

```yaml
- ${VOL_CONFIG_PATH}
```

- Subir o container novamente

```bash
docker compose up -d
```

## 7. Restaurando o backup do grafana

### 7.1 Para o container do grafana

```bash
# Acessar pasta do container
cd /bskp/ctr-grafana

# Parar o container
docker compose stop
```

### 7.2 Copiando o arquivo para dentro do container

- Copie o arquivo **.sql** para a pasta **/tmp** do servidor

- Depois de copiar o arquivo **.sql** para a pasta **/tmp** do servidor, copie o arquivo para dentro do container ctr-mysql

```bash
docker cp /tmp/NOME_DO_BKP.sql ctr-mysql:/tmp/
```

### 7.3 Restaurando o banco de dados

- Acesse o conteiner ctr-mysql

```bash
docker exec -it ctr-mysql bash
```

- Restaure a base de dados

```bash
mysql -u grafana -p grafana < /tmp/NOME_DO_BKP.sql
```

- Digite a senha do usuario grafana do banco de dados e aguarde o processo terminar

- Após terminar saia do container

```bash
exit
```

- Inicie o container novamente

```bash
# Acessar pasta do container
cd /bskp/ctr-grafana

# Subir o container
docker compose up -d
```

### Plugins

- Zabbix
- Business Charts
- HTML Graphics

Após instalar os plugins reinicie o container

```bash
docker compose stop

docker compose up --build -d
```

## Acessando o grafana WEB [Troca a porta caso tenha alterado no .env]

```cmd
http://<IP_SERVIDOR>:6080 
```
