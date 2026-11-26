import { Router } from "express";
import type pg from "pg";

// GET /health: diz se a API esta no ar e se consegue falar com o banco.
// Usada pelo Docker e, depois, pelo servidor na nuvem para saber se esta tudo bem.
export function healthRouter(pool: pg.Pool): Router {
  const router = Router();

  router.get("/health", async (_req, res) => {
    try {
      await pool.query("SELECT 1");
      res.json({ status: "ok", database: "ok" });
    } catch {
      res.status(503).json({ status: "error", database: "unavailable" });
    }
  });

  return router;
}
