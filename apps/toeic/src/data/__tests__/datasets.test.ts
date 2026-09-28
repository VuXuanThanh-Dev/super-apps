import fs from 'fs';
import path from 'path';
import irregular from '@/features/lookup/irregular.json';
import { Dictionary } from '@/features/lookup/dictionary';
import sample from '../sample/dataset.json';
import { DataIndex } from '../DataIndex';
import type { Dataset } from '../types';

function checkSchema(ds: Dataset) {
  const ids = new Set(ds.words.map((w) => w.id));
  const famIds = new Set(ds.families.map((f) => f.id));
  const topicCodes = new Set(ds.topics.map((t) => t.code));
  for (const w of ds.words) {
    expect(w.word).toBeTruthy();
    expect(w.lemma).toBeTruthy();
    expect(famIds.has(w.family)).toBe(true);
    expect(topicCodes.has(w.topic)).toBe(true);
  }
  for (const f of ds.families) {
    for (const m of f.members) expect(ids.has(m)).toBe(true);
  }
  for (const c of ds.collocations) expect(famIds.has(c.family)).toBe(true);
  for (const p of ds.passages) {
    expect(topicCodes.has(p.topic)).toBe(true);
    for (const q of p.questions) {
      expect(q.options).toHaveLength(4);
      expect(q.answer).toBeGreaterThanOrEqual(0);
      expect(q.answer).toBeLessThan(4);
    }
  }
}

describe('sample dataset (public, hand-written)', () => {
  it('is valid', () => {
    const ds = sample as Dataset;
    expect(ds.source).toBe('sample');
    checkSchema(ds);
    expect(ds.words.every((w) => w.definition && w.example && w.vi)).toBe(true);
  });
});

const privatePath = path.join(__dirname, '..', '..', '..', 'private-data', 'dataset.json');
const hasPrivate = fs.existsSync(privatePath);

// Runs only on a machine where the private dataset was built (tools/build_data.sh).
(hasPrivate ? describe : describe.skip)('private dataset (only when private-data/dataset.json exists)', () => {
  const ds: Dataset = hasPrivate ? JSON.parse(fs.readFileSync(privatePath, 'utf8')) : (sample as Dataset);
  it('is valid and complete', () => {
    checkSchema(ds);
    expect(ds.source).toBe('private');
    expect(ds.families.filter((f) => f.book === 'tap1' || f.book === 'tap2').length).toBe(312);
    expect(ds.words.length).toBeGreaterThanOrEqual(1100);
    expect(ds.words.every((w) => w.definition && w.example && w.vi)).toBe(true);
  });
  it('maps word forms to book entries', () => {
    const dict = new Dictionary({
      index: new DataIndex(ds),
      functionWords: {},
      genericGlosses: {},
      irregular: irregular as Record<string, string>,
    });
    const cases: [string, string][] = [
      ['negotiations', 'negotiation'],
      ['complied', 'comply'],
      ['Agreements', 'agreement'],
      ["supplier's", 'supplier'],
      ['shipped', 'ship'],
      ['renewing', 'renew'],
    ];
    for (const [q, lemma] of cases) {
      const r = dict.lookup(q);
      expect(r.kind).toBe('entry');
      if (r.kind === 'entry') expect(r.word.word).toBe(lemma);
    }
  });
});
