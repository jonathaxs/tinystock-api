import { createApp } from "./app.js";
import { loadConfig } from "./config.js";
import { createPool } from "./db/pool.js";

const config = loadConfig();
const pool = createPool(config.DATABASE_URL);
const app = createApp(pool);

const server = app.listen(config.PORT, () => {
  console.log(`API rodando em http://localhost:${config.PORT}`);
});

// Ao receber Ctrl+C ou o aviso de parada do Docker, termina as requisicoes e fecha o banco.
function shutdown(signal: string) {
  console.log(`${signal} recebido, desligando`);
  server.close(() => {
    pool.end().finally(() => process.exit(0));
  });
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));
