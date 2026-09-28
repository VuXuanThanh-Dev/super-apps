import { dataIndex } from '@/data';
import { foldVietnamese, searchWords, topicSummaries } from '../search';

describe('vocabulary search', () => {
  it('finds English words, exact match first', () => {
    const r = searchWords(dataIndex, 'manage');
    expect(r[0]?.word).toBe('manage');
    expect(r.map((w) => w.word)).toEqual(expect.arrayContaining(['manager', 'management']));
  });

  it('is case-insensitive and trims', () => {
    expect(searchWords(dataIndex, '  TICKET ')[0]?.word).toBe('ticket');
  });

  it('finds Vietnamese meanings with or without accents', () => {
    expect(searchWords(dataIndex, 'công ty')[0]?.word).toBe('company');
    expect(searchWords(dataIndex, 'cong ty')[0]?.word).toBe('company');
    expect(foldVietnamese('Đặt chỗ')).toBe('dat cho');
  });

  it('can filter by unit', () => {
    const r = searchWords(dataIndex, 'e', { topic: 'S2' });
    expect(r.length).toBeGreaterThan(0);
    expect(r.every((w) => w.topic === 'S2')).toBe(true);
  });

  it('returns nothing for an empty query', () => {
    expect(searchWords(dataIndex, '   ')).toEqual([]);
  });

  it('summarizes units with counts', () => {
    const s = topicSummaries(dataIndex);
    expect(s.map((t) => t.code)).toEqual(['S1', 'S2']);
    expect(s[0]?.families).toBe(5);
    expect(s[0]?.words).toBe(9);
  });
});
