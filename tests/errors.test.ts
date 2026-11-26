import request from "supertest";
import { afterAll, describe, expect, it } from "vitest";
import { createApp } from "../src/app.js";
import { createPool } from "../src/db/pool.js";
import { TEST_DATABASE_URL } from "./helpers.js";

describe("erros padronizados", () => {
  const pool = createPool(TEST_DATABASE_URL);
  afterAll(() => pool.end());

  it("devolve 400 para JSON mal formado", async () => {
    const res = await request(createApp(pool))
      .post("/qualquer")
      .set("Content-Type", "application/json")
      .send("{ isso nao e json");

    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("invalid_json");
  });

  // Exercicio: escreva aqui o teste de rota inexistente.
  // GET /nao-existe deve responder 404 com error.code igual a "not_found".
});
