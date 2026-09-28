import type { SqlDb } from '@/notes/sqlDb';

// Adapter: bọc `node:sqlite` (có sẵn trong Node 22) thành interface SqlDb giống expo-sqlite.
// Chỉ dùng trong test — trên iPhone ta dùng expo-sqlite thật.
export function createNodeSqliteDb(): SqlDb {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const { DatabaseSync } = require('node:sqlite');
  const db = new DatabaseSync(':memory:');
  const plain = <T>(row: unknown) => (row ? ({ ...(row as object) } as T) : null);
  return {
    async execAsync(sql) {
      db.exec(sql);
    },
    async runAsync(sql, ...params) {
      return db.prepare(sql).run(...params);
    },
    async getAllAsync<T>(sql: string, ...params: (string | number)[]) {
      return (db.prepare(sql).all(...params) as unknown[]).map((r) => plain<T>(r) as T);
    },
    async getFirstAsync<T>(sql: string, ...params: (string | number)[]) {
      return plain<T>(db.prepare(sql).get(...params));
    },
  };
}
