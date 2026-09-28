import { dataIndex } from '@/data';
import type { Card } from '@/storage/types';
import { buildQueue } from '../queue';
import { isLearned, newCard, review } from '../sm2';

describe('SM-2', () => {
  const today = 20000;

  it('starts with ease 2.5 and due today', () => {
    expect(newCard('Run', today)).toMatchObject({ word: 'run', ease: 2.5, interval: 0, repetitions: 0, due: today });
  });

  it('follows the 1 day, 6 days, then interval × ease schedule', () => {
    let c = newCard('run', today);
    c = review(c, 'good', today);
    expect(c).toMatchObject({ interval: 1, repetitions: 1, due: today + 1, ease: 2.5 });
    c = review(c, 'good', today + 1);
    expect(c).toMatchObject({ interval: 6, repetitions: 2, due: today + 7 });
    c = review(c, 'good', today + 7);
    expect(c.interval).toBe(15); // round(6 * 2.5)
    expect(isLearned(c)).toBe(true);
  });

  it('easy raises ease, hard lowers it, never below 1.3', () => {
    expect(review(newCard('a', today), 'easy', today).ease).toBe(2.6);
    expect(review(newCard('a', today), 'hard', today).ease).toBe(2.36);
    let c = newCard('a', today);
    for (let i = 0; i < 20; i++) c = review(c, 'hard', today);
    expect(c.ease).toBe(1.3);
  });

  it('again does not change the ease factor (original SM-2)', () => {
    expect(review(newCard('a', today), 'again', today).ease).toBe(2.5);
  });

  it('again resets repetitions and counts a lapse', () => {
    let c = review(review(newCard('a', today), 'good', today), 'good', today + 1);
    c = review(c, 'again', today + 7);
    expect(c).toMatchObject({ repetitions: 0, interval: 1, lapses: 1, due: today + 8 });
    expect(isLearned(c)).toBe(false);
  });
});

describe('study queue', () => {
  const today = 100;
  const words = dataIndex.words;

  it('puts due cards first (oldest first), then new words up to the limit', () => {
    const cards: Card[] = [
      { ...newCard('meeting', 0), due: 99, repetitions: 1, interval: 1 },
      { ...newCard('company', 0), due: 90, repetitions: 1, interval: 1 },
      { ...newCard('ticket', 0), due: 150, repetitions: 3, interval: 20 },
    ];
    const q = buildQueue(words, cards, { today, newLimit: 3 });
    expect(q.slice(0, 2).map((w) => w.word)).toEqual(['company', 'meeting']);
    expect(q).toHaveLength(5);
    expect(q.map((w) => w.word)).not.toContain('ticket');
  });
});
