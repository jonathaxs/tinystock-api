# tinystock-api

API REST do TinyStock, app de estoque e pedidos para pequenos negócios. Ela vai sincronizar os dados entre o app iOS, o app Android e a versão web.

Em construção. Hoje o repositório tem o banco de dados (tabelas, migrações e dados de exemplo), a estrutura da API com a rota `/health` e os testes automatizados.

## Tecnologias

- Node.js 24+ com TypeScript
- Express 5
- PostgreSQL 18, com SQL escrito à mão pelo driver `pg` (sem ORM)
- Zod para validar configuração e dados
- Vitest e Supertest para os testes
- Docker e Docker Compose

## Como rodar

Precisa do Docker e do Node.js instalados.

```bash
npm install
cp .env.example .env
```

### Tudo no Docker

```bash
docker compose up -d --build
curl http://localhost:3000/health
```

Ao subir, a API aplica as migrações que faltam.

### API no Mac, banco no Docker (desenvolvimento)

```bash
docker compose up -d --wait db
npm run db:migrate
npm run db:seed
npm run dev
```

O `npm run dev` reinicia a API a cada arquivo salvo. O `db:seed` coloca dados fictícios e só roda com o banco vazio.

### Testes

Com o banco ligado:

```bash
npm test
```

Os testes usam um banco separado, `tinystock_test`, recriado do zero a cada execução.

### Desligar

```bash
docker compose down
```

Os dados continuam no volume. Para apagar tudo, use `docker compose down -v`.

Para abrir o terminal do PostgreSQL: `docker compose exec db psql -U tinystock`.

## Estrutura

```
src/
  app.ts          monta a aplicação Express (usada pelo servidor e pelos testes)
  server.ts       abre a porta e desliga com segurança
  config.ts       lê e valida as variáveis de ambiente
  db/             conexão com o banco e aplicação das migrações
  routes/         rotas da API
  middleware/     tratamento de erros
  scripts/        comandos db:migrate e db:seed
db/
  migrations/     tabelas, em arquivos numerados na ordem em que rodam
  seed.sql        dados fictícios para desenvolvimento
  consultas.sql   exercícios de SQL sobre os dados de exemplo
tests/            testes automatizados
```

## Rotas

| Método | Caminho   | Descrição                                   |
| ------ | --------- | ------------------------------------------- |
| GET    | `/health` | Diz se a API está no ar e se o banco responde |

Erros seguem sempre o mesmo formato:

```json
{ "error": { "code": "not_found", "message": "Rota GET /x nao existe" } }
```

## Modelo de dados

- `users`: contas.
- `stores`: lojas de cada conta.
- `products` e `variants`: produtos e suas variações (tamanho, cor). O estoque fica na variação.
- `stock_movements`: histórico de entradas e saídas do estoque.
- `sales_orders` e `sales_order_items`: pedidos e seus itens, com preço e custo copiados na hora da venda.
- `schema_migrations`: quais arquivos de migração já foram aplicados.

Toda tabela de dados tem `updated_at` e `deleted_at`, usados pela sincronização entre aparelhos.
