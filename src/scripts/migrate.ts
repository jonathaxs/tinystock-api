import { loadConfig } from "../config.js";
import { runMigrations } from "../db/migrate.js";
import { createPool } from "../db/pool.js";

const pool = createPool(loadConfig().DATABASE_URL);

try {
  const applied = await runMigrations(pool);
  console.log(applied.length ? `Migracoes aplicadas: ${applied.join(", ")}` : "Banco ja esta atualizado");
} catch (error) {
  console.error((error as Error).message);
  process.exitCode = 1;
} finally {
  await pool.end();
}
