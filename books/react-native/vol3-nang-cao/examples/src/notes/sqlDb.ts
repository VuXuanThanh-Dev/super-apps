// Phần nhỏ của API SQLiteDatabase (expo-sqlite) mà app cần — giống Tập 2, Chương 3.
export interface SqlDb {
  execAsync(sql: string): Promise<void>;
  runAsync(sql: string, ...params: (string | number)[]): Promise<unknown>;
  getAllAsync<T>(sql: string, ...params: (string | number)[]): Promise<T[]>;
  getFirstAsync<T>(sql: string, ...params: (string | number)[]): Promise<T | null>;
}
