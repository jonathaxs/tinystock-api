-- Consultas de pratica sobre os dados de exemplo (db/seed.sql).
--
-- Como rodar: com o banco ligado (docker compose up -d), abra o psql com
--   docker compose exec db psql -U tinystock
-- e cole uma consulta por vez. Para sair do psql: \q
--
-- Cada exercicio tem o enunciado e o espaco para a consulta logo abaixo.

-- 1. Produtos da Loja Centro na ordem da tela (sort_order), com nome e preco de venda.
--    Treina: WHERE, ORDER BY e uma subconsulta ou JOIN para achar a loja pelo nome.


-- 2. Estoque total de cada produto (soma das variacoes), do maior para o menor.
--    Treina: JOIN, SUM e GROUP BY.


-- 3. Produtos com estoque total abaixo do estoque minimo.
--    Treina: HAVING (filtro depois do GROUP BY).


-- 4. Unidades vendidas e faturamento de cada produto, sem contar pedidos cancelados.
--    Faturamento = soma de unit_price * quantity.
--    Treina: JOIN entre pedidos e itens, WHERE e GROUP BY.


-- 5. Faturamento, custo e lucro por mes, sem pedidos cancelados.
--    Lucro = faturamento - custo dos itens - taxa do canal (channel_fee_amount).
--    Cuidado: a taxa e do pedido, nao do item. Somar a taxa depois do JOIN com os itens
--    repete o valor para cada item. Dica: date_trunc('month', ordered_at).


-- 6. Quantidade de pedidos por canal de venda, do canal com mais pedidos para o com menos.
--    Treina: COUNT e GROUP BY.


-- 7. Pedidos em aberto (nem concluidos nem cancelados), com comprador, loja e prazo de envio,
--    do prazo mais proximo para o mais distante; pedidos sem prazo no fim.
--    Treina: NOT IN, JOIN com lojas e ORDER BY com NULLS LAST.


-- 8. A pessoa que mais gastou, somando todos os pedidos dela que nao foram cancelados.
--    Treina: GROUP BY, ORDER BY e LIMIT.

