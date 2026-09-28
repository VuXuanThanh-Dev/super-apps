/** Split text into tokens for rendering. Every character is kept, so joining
 * all token texts gives back the original string.
 * A word is letters, optionally joined by an apostrophe or hyphen:
 * "company's", "don't", "long-term", "Ms". Numbers and punctuation are not words. */
export interface Token {
  text: string;
  isWord: boolean;
}

const WORD_RE = /[A-Za-zÀ-ɏ]+(?:['’\-][A-Za-zÀ-ɏ]+)*/g;

export function tokenize(text: string): Token[] {
  const tokens: Token[] = [];
  let last = 0;
  for (const m of text.matchAll(WORD_RE)) {
    const start = m.index ?? 0;
    if (start > last) tokens.push({ text: text.slice(last, start), isWord: false });
    tokens.push({ text: m[0], isWord: true });
    last = start + m[0].length;
  }
  if (last < text.length) tokens.push({ text: text.slice(last), isWord: false });
  return tokens;
}
