/** Map a word form to candidate dictionary forms (lemmas), best first.
 * "ran" -> run, "companies" -> company, "company's" -> company, "don't" -> do.
 * Rules: exact form, irregular table (WordNet exception lists), contractions,
 * possessives, then English suffix rules (-ies, -es, -s, -ied, -ed, -ing, -er, -est). */

export interface Normalized {
  /** lower-case word without possessive/contraction */
  base: string;
  /** full lower-case form as typed (with apostrophe normalized) */
  full: string;
  /** e.g. "don't = do not" */
  contraction?: string;
}

const CONTRACTIONS: Record<string, [string, string]> = {
  "won't": ['will', 'will not'],
  "can't": ['can', 'cannot'],
  "shan't": ['shall', 'shall not'],
  "ain't": ['be', 'am not / is not'],
  "let's": ['let', 'let us'],
  "i'm": ['i', 'I am'],
};
const SUFFIX_CONTRACTIONS: [string, string][] = [
  ["n't", 'not'],
  ["'re", 'are'],
  ["'ve", 'have'],
  ["'ll", 'will'],
  ["'d", 'would / had'],
  ["'m", 'am'],
];

const S_IS_HAS = new Set(['it', 'he', 'she', 'that', 'what', 'there', 'here', 'who', 'where', 'how']);

export function normalizeToken(raw: string): Normalized {
  const full = raw
    .replace(/[’‘`]/g, "'")
    .replace(/^[^A-Za-zÀ-ɏ]+|[^A-Za-zÀ-ɏ']+$/g, '')
    .replace(/^'+/, '')
    .toLowerCase();
  const special = CONTRACTIONS[full];
  if (special) return { base: special[0], full, contraction: `${full} = ${special[1]}` };
  for (const [suffix, meaning] of SUFFIX_CONTRACTIONS) {
    if (full.endsWith(suffix) && full.length > suffix.length) {
      const stem = full.slice(0, -suffix.length);
      return { base: stem, full, contraction: `${full} = ${stem} ${meaning}` };
    }
  }
  // possessive: company's -> company, companies' -> companies
  if (full.endsWith("'s")) {
    const stem = full.slice(0, -2);
    if (S_IS_HAS.has(stem)) return { base: stem, full, contraction: `${full} = ${stem} is / ${stem} has` };
    return { base: stem, full };
  }
  if (full.endsWith("'")) return { base: full.slice(0, -1), full };
  return { base: full, full };
}

const VOWEL = /[aeiou]/;

export function lemmaCandidates(word: string, irregular: Record<string, string>): string[] {
  const w = word.toLowerCase();
  const out: string[] = [w];
  const add = (s: string | undefined) => {
    if (s && s.length > 1 && !out.includes(s)) out.push(s);
  };
  add(irregular[w]);
  const len = w.length;
  if (len > 3 && w.endsWith('ies')) add(w.slice(0, -3) + 'y');
  if (len > 3 && w.endsWith('ied')) add(w.slice(0, -3) + 'y');
  if (len > 4 && w.endsWith('iest')) add(w.slice(0, -4) + 'y');
  if (len > 3 && w.endsWith('ier')) add(w.slice(0, -3) + 'y');
  if (len > 3 && /(ss|sh|ch|x|z|o)es$/.test(w)) add(w.slice(0, -2));
  if (len > 2 && w.endsWith('s') && !w.endsWith('ss')) add(w.slice(0, -1));
  if (len > 3 && w.endsWith('ed')) {
    const stem = w.slice(0, -2);
    add(stem); // delivered -> deliver
    add(w.slice(0, -1)); // approved -> approve
    if (/([bcdfghjklmnpqrstvz])\1$/.test(stem)) add(stem.slice(0, -1)); // planned -> plan
  }
  if (len > 4 && w.endsWith('ing')) {
    const stem = w.slice(0, -3);
    if (VOWEL.test(stem)) {
      add(stem); // meeting -> meet
      add(stem + 'e'); // negotiating -> negotiate
      if (/([bcdfghjklmnpqrstvz])\1$/.test(stem)) add(stem.slice(0, -1)); // shipping -> ship
    }
  }
  if (len > 4 && w.endsWith('est')) {
    add(w.slice(0, -3));
    add(w.slice(0, -2));
  }
  if (len > 3 && w.endsWith('er')) {
    add(w.slice(0, -2)); // cheaper -> cheap
    add(w.slice(0, -1)); // safer -> safe
  }
  return out;
}
