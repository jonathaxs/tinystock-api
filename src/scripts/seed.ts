import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { loadConfig } from "../config.js";
import { createPool } from "../db/pool.js";

// Coloca os dados ficticios de db/seed.sql. So para desenvolvimento.
// Se ja existir algum usuario, nao faz nada, para nao duplicar.
const seedFile = fileURLToPath(new URL("../../db/seed.sql", import.meta.url));
const pool = createPool(loadConfig().DATABASE_URL);

try {
  const { rowCount } = await pool.query("SELECT 1 FROM users LIMIT 1");
  if (rowCount) {
    console.log("O banco ja tem dados, seed ignorado");
  } else {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query(await readFile(seedFile, "utf8"));
      await client.query("COMMIT");
      console.log("Dados de exemplo inseridos");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }
} catch (error) {
  console.error((error as Error).message);
  process.exitCode = 1;
} finally {
  await pool.end();
}
