import type { Note, NoteInput } from './model';
import type { SqlDb } from './sqlDb';

export interface NotesRepository {
  list(): Promise<Note[]>;
  get(id: string): Promise<Note | null>;
  create(input: NoteInput, id: string, now: number): Promise<Note>;
  update(id: string, input: NoteInput, now: number): Promise<void>;
  remove(id: string): Promise<void>;
}

export async function migrate(db: SqlDb): Promise<void> {
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS notes (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    );
  `);
}

interface Row {
  id: string;
  title: string;
  body: string;
  updated_at: number;
}
const toNote = (r: Row): Note => ({ id: r.id, title: r.title, body: r.body, updatedAt: r.updated_at });

export function createSqliteNotesRepository(db: SqlDb): NotesRepository {
  return {
    async list() {
      const rows = await db.getAllAsync<Row>('SELECT * FROM notes ORDER BY updated_at DESC');
      return rows.map(toNote);
    },
    async get(id) {
      const row = await db.getFirstAsync<Row>('SELECT * FROM notes WHERE id = ?', id);
      return row ? toNote(row) : null;
    },
    async create(input, id, now) {
      await db.runAsync('INSERT INTO notes (id, title, body, updated_at) VALUES (?, ?, ?, ?)', id, input.title.trim(), input.body, now);
      return { id, title: input.title.trim(), body: input.body, updatedAt: now };
    },
    async update(id, input, now) {
      await db.runAsync('UPDATE notes SET title = ?, body = ?, updated_at = ? WHERE id = ?', input.title.trim(), input.body, now, id);
    },
    async remove(id) {
      await db.runAsync('DELETE FROM notes WHERE id = ?', id);
    },
  };
}
