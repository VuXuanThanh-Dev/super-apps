import { defaultDictionary as dict } from '../defaultDictionary';

describe('Dictionary (sample dataset, offline)', () => {
  it('finds a dataset word with family and collocations', () => {
    const r = dict.lookup('manage');
    expect(r.kind).toBe('entry');
    if (r.kind !== 'entry') return;
    expect(r.word.vi).toBe('quản lý');
    expect(r.word.definition).toBeTruthy();
    expect(r.word.ipa).toMatch(/^\//);
    expect(r.family.map((w) => w.word)).toEqual(['manage', 'manager', 'management']);
    expect(r.collocations.length).toBeGreaterThan(0);
  });

  it('maps irregular forms to the lemma: ran -> run', () => {
    const r = dict.lookup('ran');
    expect(r.kind).toBe('entry');
    if (r.kind === 'entry') {
      expect(r.word.word).toBe('run');
      expect(r.via).toBe('ran → run');
    }
  });

  it('maps plurals and possessives: companies, company\'s -> company', () => {
    for (const q of ['companies', "company's", 'Company', 'COMPANIES', "companies'", 'company’s']) {
      const r = dict.lookup(q);
      expect(r.kind).toBe('entry');
      if (r.kind === 'entry') expect(r.word.word).toBe('company');
    }
  });

  it('strips punctuation around the word', () => {
    const r = dict.lookup('"meetings,"');
    expect(r.kind).toBe('entry');
    if (r.kind === 'entry') expect(r.word.word).toBe('meeting');
  });

  it('handles verb forms: delayed, booking, reports, met', () => {
    const cases: [string, string][] = [
      ['delayed', 'delayed'],
      ['delays', 'delay'],
      ['booking', 'booking'],
      ['booked', 'book'],
      ['reports', 'report'],
      ['met', 'meet'],
      ['managed', 'manage'],
      ['managing', 'manage'],
    ];
    for (const [q, lemma] of cases) {
      const r = dict.lookup(q);
      expect(r.kind).toBe('entry');
      if (r.kind === 'entry') expect(r.word.word).toBe(lemma);
    }
  });

  it("explains contractions: don't -> do (function word)", () => {
    const r = dict.lookup("don't");
    expect(r.kind).toBe('function');
    if (r.kind === 'function') {
      expect(r.lemma).toBe('do');
      expect(r.contraction).toBe("don't = do not");
    }
  });

  it('uses WordNet glosses for other words in the app texts', () => {
    const r = dict.lookup('printer');
    expect(r.kind).toBe('gloss');
  });

  it('shows not found for unknown words', () => {
    expect(dict.lookup('blorptastic').kind).toBe('notfound');
    expect(dict.lookup('   ').kind).toBe('notfound');
    expect(dict.lookup('...').kind).toBe('notfound');
  });
});
