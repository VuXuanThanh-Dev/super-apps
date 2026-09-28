import { bumpFromCommits, bumpVersion } from './version';

describe('Tập 3 — Chương 6: phiên bản', () => {
  it.each([
    ['1.4.2', 'patch', '1.4.3'],
    ['1.4.2', 'minor', '1.5.0'],
    ['1.4.2', 'major', '2.0.0'],
  ] as const)('bumpVersion(%p, %p) → %p', (v, k, expected) => {
    expect(bumpVersion(v, k)).toBe(expected);
  });

  it('từ chối phiên bản sai định dạng', () => {
    expect(() => bumpVersion('1.4', 'patch')).toThrow('Phiên bản không hợp lệ: 1.4');
  });

  it('bài tập: bumpFromCommits', () => {
    expect(bumpFromCommits(['fix: sửa lỗi PIN', 'docs: README'])).toBe('patch');
    expect(bumpFromCommits(['feat(notes): tìm kiếm', 'fix: typo'])).toBe('minor');
    expect(bumpFromCommits(['feat!: đổi định dạng dữ liệu'])).toBe('major');
    expect(bumpFromCommits(['chore: dọn dẹp'])).toBeNull();
  });
});
