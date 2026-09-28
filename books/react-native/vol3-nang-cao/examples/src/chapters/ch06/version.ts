// Chương 6: phiên bản khi phát hành.
// - "version" (1.4.2): người dùng thấy trên App Store / Play Store (marketing version).
// - ios.buildNumber / android.versionCode: số build, phải TĂNG mỗi lần upload lên store.
export type Bump = 'major' | 'minor' | 'patch';

export function bumpVersion(version: string, kind: Bump): string {
  const m = /^(\d+)\.(\d+)\.(\d+)$/.exec(version);
  if (!m) throw new Error(`Phiên bản không hợp lệ: ${version}`);
  let [major, minor, patch] = m.slice(1).map(Number);
  if (kind === 'major') [major, minor, patch] = [major + 1, 0, 0];
  else if (kind === 'minor') [minor, patch] = [minor + 1, 0];
  else patch += 1;
  return `${major}.${minor}.${patch}`;
}

// Lời giải bài tập: chọn loại tăng phiên bản từ danh sách commit (Conventional Commits).
export function bumpFromCommits(messages: string[]): Bump | null {
  if (messages.some((m) => /^[a-z]+(\(.+\))?!:/.test(m) || /BREAKING CHANGE/.test(m))) return 'major';
  if (messages.some((m) => /^feat(\(.+\))?:/.test(m))) return 'minor';
  if (messages.some((m) => /^fix(\(.+\))?:/.test(m))) return 'patch';
  return null;
}
