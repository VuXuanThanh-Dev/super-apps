import { tokenize } from '../tokenize';

describe('tokenize', () => {
  it('keeps every character (round trip)', () => {
    const text = 'Hello, Ms. Tran! The company\'s long-term plan—don\'t worry (2026).';
    expect(tokenize(text).map((t) => t.text).join('')).toBe(text);
  });

  it('marks words and keeps apostrophes and hyphens inside words', () => {
    const words = tokenize("The company's long-term plan: don't stop.").filter((t) => t.isWord).map((t) => t.text);
    expect(words).toEqual(['The', "company's", 'long-term', 'plan', "don't", 'stop']);
  });

  it('does not treat numbers and punctuation as words', () => {
    const words = tokenize('Call 0903-555, now!').filter((t) => t.isWord).map((t) => t.text);
    expect(words).toEqual(['Call', 'now']);
  });

  it('handles curly apostrophes', () => {
    const words = tokenize('It’s the manager’s desk.').filter((t) => t.isWord).map((t) => t.text);
    expect(words).toEqual(['It’s', 'the', 'manager’s', 'desk']);
  });

  it('returns nothing for empty text', () => {
    expect(tokenize('')).toEqual([]);
  });
});
