import express from "express";
import type pg from "pg";
import { errorHandler, notFound } from "./middleware/errors.js";
import { healthRouter } from "./routes/health.js";

// Monta a aplicacao sem abrir porta. Os testes usam esta funcao direto, com o Supertest.
export function createApp(pool: pg.Pool): express.Express {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json({ limit: "1mb" }));

  app.use(healthRouter(pool));

  app.use(notFound);
  app.use(errorHandler);

  return app;
}
