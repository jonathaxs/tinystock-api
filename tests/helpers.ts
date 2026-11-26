// Os testes usam um banco separado (tinystock_test), para nunca mexer nos dados de desenvolvimento.
export const TEST_DATABASE_URL =
  process.env.TEST_DATABASE_URL ?? "postgres://tinystock:tinystock@localhost:5432/tinystock_test";
