import type { ErrorRequestHandler, RequestHandler } from "express";

// Formato unico de erro em toda a API: { "error": { "code": "...", "message": "..." } }

export const notFound: RequestHandler = (req, res) => {
  res.status(404).json({
    error: { code: "not_found", message: `Rota ${req.method} ${req.path} nao existe` },
  });
};

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  // JSON mal formado no corpo da requisicao.
  if (err?.type === "entity.parse.failed") {
    res.status(400).json({ error: { code: "invalid_json", message: "Corpo da requisicao nao e um JSON valido" } });
    return;
  }

  console.error(err);
  res.status(500).json({ error: { code: "internal_error", message: "Erro interno no servidor" } });
};
