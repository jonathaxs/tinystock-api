import request from "supertest";
import { afterAll, describe, expect, it } from "vitest";
import { createApp } from "../src/app.js";
import { createPool } from "../src/db/pool.js";
import { TEST_DATABASE_URL } from "./helpers.js";

describe("GET /health", () => {
  const pool = createPool(TEST_DATABASE_URL);
  afterAll(() => pool.end());

  it("responde ok quando o banco esta no ar", async () => {
    const res = await request(createApp(pool)).get("/health");

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok", database: "ok" });
  });

  it("responde 503 quando nao consegue falar com o banco", async () => {
    // Porta 1: nada escuta ali, entao a conexao falha na hora.
    const brokenPool = createPool("postgres://tinystock:tinystock@127.0.0.1:1/tinystock");
    const res = await request(createApp(brokenPool)).get("/health");
    await brokenPool.end();

    expect(res.status).toBe(503);
    expect(res.body).toEqual({ status: "error", database: "unavailable" });
  });
});
