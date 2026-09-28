import irregular from '../irregular.json';
import { lemmaCandidates, normalizeToken } from '../lemmatize';

const irr = irregular as Record<string, string>;

describe('normalizeToken', () => {
  it.each([
    ['Company', 'company'],
    ['COMPANY', 'company'],
    ["company's", 'company'],
    ['company’s', 'company'],
    ["companies'", 'companies'],
    ['"meeting,"', 'meeting'],
    ['(delay)', 'delay'],
    ['report.', 'report'],
  ])('%s -> %s', (raw, base) => {
    expect(normalizeToken(raw).base).toBe(base);
  });

  it.each([
    ["don't", 'do', "don't = do not"],
    ["Don't", 'do', "don't = do not"],
    ["can't", 'can', "can't = cannot"],
    ["won't", 'will', "won't = will not"],
    ["isn't", 'is', "isn't = is not"],
    ["we're", 'we', "we're = we are"],
    ["I'll", 'i', "i'll = i will"],
    ["they've", 'they', "they've = they have"],
    ["it's", 'it', "it's = it is / it has"],
  ])('contraction %s -> %s', (raw, base, note) => {
    const n = normalizeToken(raw);
    expect(n.base).toBe(base);
    expect(n.contraction).toBe(note);
  });
});

describe('lemmaCandidates', () => {
  it.each([
    ['ran', 'run'],
    ['went', 'go'],
    ['bought', 'buy'],
    ['children', 'child'],
    ['taken', 'take'],
    ['met', 'meet'],
    ['better', 'good'],
  ])('irregular %s -> %s', (form, lemma) => {
    expect(lemmaCandidates(form, irr)).toContain(lemma);
  });

  it.each([
    ['companies', 'company'],
    ['applied', 'apply'],
    ['boxes', 'box'],
    ['reports', 'report'],
    ['delivered', 'deliver'],
    ['approved', 'approve'],
    ['planned', 'plan'],
    ['negotiating', 'negotiate'],
    ['meeting', 'meet'],
    ['shipping', 'ship'],
    ['cheaper', 'cheap'],
    ['safest', 'safe'],
  ])('regular %s -> %s', (form, lemma) => {
    expect(lemmaCandidates(form, irr)).toContain(lemma);
  });

  it('always tries the exact form first', () => {
    expect(lemmaCandidates('meeting', irr)[0]).toBe('meeting');
    expect(lemmaCandidates('news', irr)[0]).toBe('news');
  });
});
