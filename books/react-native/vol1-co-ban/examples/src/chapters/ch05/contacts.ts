export interface Contact {
  id: string;
  name: string;
  phone: string;
}

export const CONTACTS: Contact[] = [
  { id: '1', name: 'Đặng Minh', phone: '0901 111 111' },
  { id: '2', name: 'An Nguyễn', phone: '0902 222 222' },
  { id: '3', name: 'Bình Trần', phone: '0903 333 333' },
  { id: '4', name: 'Ánh Lê', phone: '0904 444 444' },
  { id: '5', name: 'Dũng Phạm', phone: '0905 555 555' },
  { id: '6', name: 'Bảo Võ', phone: '0906 666 666' },
];

// Bỏ dấu tiếng Việt để tìm kiếm và nhóm: "Ánh" → "anh", "Đặng" → "dang".
export function removeDiacritics(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D');
}

export function searchContacts(list: Contact[], query: string): Contact[] {
  const q = removeDiacritics(query.trim().toLowerCase());
  if (!q) return list;
  return list.filter((c) => removeDiacritics(c.name.toLowerCase()).includes(q) || c.phone.replace(/\s/g, '').includes(q));
}

export interface ContactSection {
  title: string;
  data: Contact[];
}

// Nhóm theo chữ cái đầu (đã bỏ dấu) cho SectionList.
export function groupByLetter(list: Contact[]): ContactSection[] {
  const map = new Map<string, Contact[]>();
  for (const c of list) {
    const letter = removeDiacritics(c.name.charAt(0)).toUpperCase();
    map.set(letter, [...(map.get(letter) ?? []), c]);
  }
  return [...map.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([title, data]) => ({ title, data: [...data].sort((x, y) => x.name.localeCompare(y.name, 'vi')) }));
}
