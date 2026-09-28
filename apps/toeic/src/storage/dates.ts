/** Local calendar helpers. A "day number" counts days since 1970-01-01 for the
 * LOCAL date, so a review at 23:59 and one at 00:01 are on different days. */
export function localDayString(d: Date = new Date()): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

export function dayNumberFromString(s: string): number {
  const [y, m, d] = s.split('-').map(Number);
  return Math.floor(Date.UTC(y ?? 1970, (m ?? 1) - 1, d ?? 1) / 86_400_000);
}

export function dayNumber(d: Date = new Date()): number {
  return dayNumberFromString(localDayString(d));
}

export function dayStringFromNumber(n: number): string {
  const d = new Date(n * 86_400_000);
  return d.toISOString().slice(0, 10);
}
