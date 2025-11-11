# Zabbix Proxy com Docker Compose

Este repositório contém a configuração para subir um container Zabbix Proxy utilizando MySQL como backend.

## Pré-requisitos

- Docker e Docker Compose.
- Rede Docker network-share já criada:
- Container ctr-mysql rodando.
- Container Zabbix Server rodando.

## Criar a rede externa se ainda não existir

Observe que a rede deve ser do tipo `bridge` e com um subnet que não conflite com outras redes na sua infraestrutura.

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
````

## Estrutura de arquivos

```bash
bskp/
└── ctr-zbx-proxy            # Projeto Zabbix - Proxy
     ├── docker-compose.yml  # Definição dos serviços Docker
     ├── .env.example        # Exemplo de variáveis de ambiente
     └── README.md           # Documentação do serviço
```

## Configuração das variáveis de ambiente

Copie o template e preencha os valores:

```bash
cp /bskp/ctr-zbx-proxy/.env.example /bskp/ctr-zbx-proxy/.env
```

## Criando a base de dados

### Acesse o container do ctr-mysql e crie a base de dados para o Zabbix:

```bash
docker exec -it ctr-mysql mysql -u root -p
```

```sql
CREATE DATABASE IF NOT EXISTS zabbix_proxy CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'zbxproxy'@'%' IDENTIFIED BY 'X95!HZ*3fpqZ';
GRANT ALL PRIVILEGES ON zabbix_proxy.* TO 'zbxproxy'@'%';
FLUSH PRIVILEGES;
exit
```

## Subindo o container

```bash
docker compose up -d
```

## Verifique os logs

```bash
docker logs -f ctr-zbx-proxy
```

## Adicionando o Proxy no Zabbix

1. Acesse a interface do Zabbix Server.
2. Vá em Administration → Proxies → Create proxy.
3. Preencha os campos:
   - Proxy name: igual ao valor de ZBX_HOSTNAME do .env (ex.: ctr-zbx-proxy).
   - Proxy mode: Active (ou Passive, se configurado).
   - Proxy address: IP ou DNS do container (ex.: 172.18.0.12 ou o IP do host com porta 10051).
   - Description: opcional.
   - Clique em Add.

## Testando comunicação

No host do servidor Zabbix:

>OBS: colocar o nome do proxy conforme configurado no .env

```bash
docker exec -it ctr-zbx-proxy zabbix_proxy -T
```

Retorno esperado se tudo estiver OK:

```bash
Validating configuration file "/etc/zabbix/zabbix_proxy.conf"
Validation successful
```

Se a comunicação estiver OK, o proxy aparecerá na interface do Zabbix em alguns minutos.
