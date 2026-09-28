export interface Note {
  id: string;
  title: string;
  body: string;
  updatedAt: number;
}

export type NoteInput = Pick<Note, 'title' | 'body'>;

export function validateNote(input: NoteInput): string | undefined {
  if (!input.title.trim()) return 'Tiêu đề không được để trống';
  if (input.title.length > 100) return 'Tiêu đề tối đa 100 ký tự';
  if (input.body.length > 10_000) return 'Nội dung tối đa 10.000 ký tự';
  return undefined;
}

// Kiểm tra id từ URL/deep link trước khi dùng (không tin dữ liệu bên ngoài).
export function parseNoteId(raw: unknown): string | null {
  if (typeof raw !== 'string') return null;
  return /^[a-z0-9-]{1,40}$/.test(raw) ? raw : null;
}
