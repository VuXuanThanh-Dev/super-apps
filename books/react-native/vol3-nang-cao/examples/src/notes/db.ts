import * as SQLite from 'expo-sqlite';
import { createSqliteNotesRepository, migrate, type NotesRepository } from './repository';

// Mở database một lần (lazy) cho cả app.
let repoPromise: Promise<NotesRepository> | null = null;

export function getNotesRepository(): Promise<NotesRepository> {
  repoPromise ??= (async () => {
    const db = await SQLite.openDatabaseAsync('secure-notes.db');
    await migrate(db);
    return createSqliteNotesRepository(db);
  })();
  return repoPromise;
}

export function resetNotesRepositoryForTests() {
  repoPromise = null;
}
