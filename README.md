# tinystock-api

API REST do TinyStock, app de estoque e pedidos para pequenos negócios. Ela vai sincronizar os dados entre o app iOS, o app Android e a versão web.

Em construção. Hoje o repositório tem o banco de dados: as tabelas do PostgreSQL, dados de exemplo e consultas de prática.

## Tecnologias

- PostgreSQL 18
- Docker e Docker Compose
- Node.js com TypeScript (próxima etapa)

## Como rodar o banco

Precisa do Docker instalado.

```bash
docker compose up -d
```

Na primeira vez, o banco é criado com as tabelas de `db/migrations` e os dados de `db/seed.sql`.

Para abrir o terminal do PostgreSQL:

```bash
docker compose exec db psql -U tinystock
```

Para desligar sem perder os dados:

```bash
docker compose down
```

Para apagar tudo e recriar do zero na próxima subida:

```bash
docker compose down -v
```

## Estrutura

```
db/
  migrations/   tabelas, em arquivos numerados na ordem em que rodam
  seed.sql      dados fictícios para desenvolvimento
  consultas.sql exercícios de SQL sobre os dados de exemplo
```

## Modelo de dados

- `users`: contas.
- `stores`: lojas de cada conta.
- `products` e `variants`: produtos e suas variações (tamanho, cor). O estoque fica na variação.
- `stock_movements`: histórico de entradas e saídas do estoque.
- `sales_orders` e `sales_order_items`: pedidos e seus itens, com preço e custo copiados na hora da venda.

Toda tabela tem `updated_at` e `deleted_at`, usados pela sincronização entre aparelhos.
