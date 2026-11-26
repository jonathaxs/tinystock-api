import { afterAll, describe, expect, it } from "vitest";
import { runMigrations } from "../src/db/migrate.js";
import { createPool } from "../src/db/pool.js";
import { TEST_DATABASE_URL } from "./helpers.js";

describe("migracoes", () => {
  const pool = createPool(TEST_DATABASE_URL);
  afterAll(() => pool.end());

  it("registra cada arquivo aplicado", async () => {
    const { rows } = await pool.query<{ name: string }>("SELECT name FROM schema_migrations ORDER BY name");
    expect(rows.map((row) => row.name)).toContain("001_tabelas_iniciais.sql");
  });

  it("nao roda de novo o que ja foi aplicado", async () => {
    // O global-setup ja aplicou tudo; uma segunda rodada nao deve ter nada a fazer.
    expect(await runMigrations(pool)).toEqual([]);
  });
});
