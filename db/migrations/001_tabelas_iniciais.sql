-- Tabelas iniciais do TinyStock no PostgreSQL.
--
-- Seguem as mesmas entidades dos apps (iOS e Android), com algumas diferencas para o servidor:
--   * cada loja pertence a um usuario (users.id);
--   * toda tabela tem updated_at e deleted_at, usados pela sincronizacao: um registro apagado
--     no aparelho nao some do banco, ganha deleted_at para os outros aparelhos saberem;
--   * os ids sao UUID gerados no proprio aparelho, por isso o servidor aceita o id que chega;
--   * fotos ficam num armazenamento de arquivos; aqui guardamos so a chave (image_key).

CREATE TABLE users (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT        NOT NULL UNIQUE,
    password_hash TEXT        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE stores (
    id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                   UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name                      TEXT        NOT NULL,
    image_key                 TEXT,
    is_archived               BOOLEAN     NOT NULL DEFAULT false,
    archived_at               TIMESTAMPTZ,
    trashed_at                TIMESTAMPTZ,
    was_archived_before_trash BOOLEAN     NOT NULL DEFAULT false,
    sort_order                INTEGER     NOT NULL DEFAULT 0,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at                TIMESTAMPTZ
);

CREATE INDEX stores_user_id_idx ON stores (user_id);

CREATE TABLE products (
    id            UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id      UUID           NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    name          TEXT           NOT NULL,
    category      TEXT           NOT NULL DEFAULT '',
    minimum_stock INTEGER        NOT NULL DEFAULT 0 CHECK (minimum_stock >= 0),
    cost_price    NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (cost_price >= 0),
    sale_price    NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (sale_price >= 0),
    image_key     TEXT,
    sort_order    INTEGER        NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX products_store_id_idx ON products (store_id);

-- Todo produto tem pelo menos uma variacao (a padrao, quando nao ha tamanhos ou cores).
-- O estoque fica aqui, por variacao.
CREATE TABLE variants (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id   UUID        NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    product_id UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    name       TEXT        NOT NULL,
    is_default BOOLEAN     NOT NULL DEFAULT false,
    quantity   INTEGER     NOT NULL DEFAULT 0,
    image_key  TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX variants_store_id_idx ON variants (store_id);
CREATE INDEX variants_product_id_idx ON variants (product_id);

-- Historico de cada entrada e saida de estoque.
CREATE TABLE stock_movements (
    id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id             UUID        NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    product_id           UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    variant_id           UUID        NOT NULL REFERENCES variants (id) ON DELETE CASCADE,
    kind                 TEXT        NOT NULL CHECK (kind IN
                             ('initialStock', 'entry', 'adjustment', 'reversal', 'orderWithdrawal')),
    quantity_delta       INTEGER     NOT NULL,
    balance_after        INTEGER     NOT NULL,
    note                 TEXT        NOT NULL DEFAULT '',
    reference_id         UUID,
    reversed_movement_id UUID,
    reversed_at          TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at           TIMESTAMPTZ
);

CREATE INDEX stock_movements_store_id_idx ON stock_movements (store_id);
CREATE INDEX stock_movements_variant_id_idx ON stock_movements (variant_id);
CREATE INDEX stock_movements_reference_id_idx ON stock_movements (reference_id);

CREATE TABLE sales_orders (
    id                     UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id               UUID           NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    channel                TEXT           NOT NULL CHECK (channel IN
                               ('direct', 'shopee', 'mercadoLivre', 'other')),
    custom_channel_name    TEXT           NOT NULL DEFAULT '',
    fulfillment            TEXT           NOT NULL CHECK (fulfillment IN ('readyStock', 'production')),
    status                 TEXT           NOT NULL CHECK (status IN
                               ('new', 'awaitingProduction', 'inProduction', 'readyToShip',
                                'shipped', 'completed', 'cancelled')),
    buyer_name             TEXT           NOT NULL DEFAULT '',
    external_reference     TEXT           NOT NULL DEFAULT '',
    ordered_at             TIMESTAMPTZ    NOT NULL,
    production_due_at      TIMESTAMPTZ,
    shipping_due_at        TIMESTAMPTZ,
    production_started_at  TIMESTAMPTZ,
    produced_at            TIMESTAMPTZ,
    shipped_at             TIMESTAMPTZ,
    completed_at           TIMESTAMPTZ,
    cancelled_at           TIMESTAMPTZ,
    cancellation_reason    TEXT           NOT NULL DEFAULT '',
    tracking_code          TEXT           NOT NULL DEFAULT '',
    note                   TEXT           NOT NULL DEFAULT '',
    channel_fee_percentage NUMERIC(5, 2)  NOT NULL DEFAULT 0 CHECK (channel_fee_percentage >= 0),
    channel_fee_amount     NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (channel_fee_amount >= 0),
    created_at             TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ    NOT NULL DEFAULT now(),
    deleted_at             TIMESTAMPTZ
);

CREATE INDEX sales_orders_store_id_idx ON sales_orders (store_id);
CREATE INDEX sales_orders_ordered_at_idx ON sales_orders (ordered_at);

-- Linhas do pedido. Nome, preco e custo sao copiados na hora da venda, para o pedido antigo
-- nao mudar quando o produto for editado depois.
CREATE TABLE sales_order_items (
    id           UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id     UUID           NOT NULL REFERENCES sales_orders (id) ON DELETE CASCADE,
    store_id     UUID           NOT NULL REFERENCES stores (id) ON DELETE CASCADE,
    product_id   UUID           NOT NULL,
    variant_id   UUID           NOT NULL,
    product_name TEXT           NOT NULL,
    variant_name TEXT           NOT NULL,
    unit_price   NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    unit_cost    NUMERIC(12, 2) NOT NULL CHECK (unit_cost >= 0),
    quantity     INTEGER        NOT NULL CHECK (quantity > 0),
    position     INTEGER        NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ
);

CREATE INDEX sales_order_items_order_id_idx ON sales_order_items (order_id);
CREATE INDEX sales_order_items_store_id_idx ON sales_order_items (store_id);
