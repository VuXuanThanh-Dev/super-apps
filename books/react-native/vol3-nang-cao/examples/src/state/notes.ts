import { create } from 'zustand';
import { logger } from '@/monitoring/logger';
import { getNotesRepository } from '@/notes/db';
import type { Note, NoteInput } from '@/notes/model';

let seq = 0;
const newId = (now: number) => `${now.toString(36)}-${(seq++).toString(36)}`;

interface NotesState {
  notes: Note[];
  loaded: boolean;
  load: () => Promise<void>;
  add: (input: NoteInput) => Promise<Note>;
  update: (id: string, input: NoteInput) => Promise<void>;
  remove: (id: string) => Promise<void>;
  reset: () => void;
}

export const useNotes = create<NotesState>()((set, get) => ({
  notes: [],
  loaded: false,
  load: async () => {
    const repo = await getNotesRepository();
    set({ notes: await repo.list(), loaded: true });
  },
  add: async (input) => {
    const repo = await getNotesRepository();
    const now = Date.now();
    const note = await repo.create(input, newId(now), now);
    set({ notes: [note, ...get().notes] });
    logger.addBreadcrumb('info', 'note.create', { length: input.body.length });
    return note;
  },
  update: async (id, input) => {
    const repo = await getNotesRepository();
    const now = Date.now();
    await repo.update(id, input, now);
    const updated = get().notes.map((n) => (n.id === id ? { ...n, ...input, title: input.title.trim(), updatedAt: now } : n));
    set({ notes: updated.sort((a, b) => b.updatedAt - a.updatedAt) });
    logger.addBreadcrumb('info', 'note.update');
  },
  remove: async (id) => {
    const repo = await getNotesRepository();
    await repo.remove(id);
    set({ notes: get().notes.filter((n) => n.id !== id) });
    logger.addBreadcrumb('info', 'note.remove');
  },
  reset: () => set({ notes: [], loaded: false }),
}));
