import pg from "pg";

// NUMERIC (precos) chega como texto por padrao, para nao perder casas decimais.
// Mantemos assim: quem precisar de conta converte no lugar certo.
export function createPool(connectionString: string): pg.Pool {
  return new pg.Pool({ connectionString, max: 10 });
}
