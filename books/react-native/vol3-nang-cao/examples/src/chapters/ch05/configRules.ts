// Chương 5: "kiểm tra cấu hình như code". Chạy trong jest → chạy được trên CI trước mỗi lần build.
export interface ExpoConfigLike {
  name?: string;
  slug?: string;
  version?: string;
  scheme?: string;
  ios?: { bundleIdentifier?: string };
  android?: { package?: string };
  [key: string]: unknown;
}

export interface EasJsonLike {
  cli?: { appVersionSource?: string };
  build?: Record<string, { autoIncrement?: boolean; channel?: string; developmentClient?: boolean; distribution?: string }>;
}

const SEMVER = /^\d+\.\d+\.\d+$/;
const REVERSE_DNS = /^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$/;

export function checkAppConfig(c: ExpoConfigLike): string[] {
  const errors: string[] = [];
  if (!c.version || !SEMVER.test(c.version)) errors.push('version phải có dạng x.y.z');
  if (!c.ios?.bundleIdentifier || !REVERSE_DNS.test(c.ios.bundleIdentifier)) errors.push('ios.bundleIdentifier phải dạng reverse-DNS');
  if (!c.android?.package || !REVERSE_DNS.test(c.android.package)) errors.push('android.package phải dạng reverse-DNS');
  if (!c.scheme) errors.push('cần scheme cho deep link');
  if (/secret|password|private[_-]?key/i.test(JSON.stringify(c))) errors.push('app.json có vẻ chứa bí mật');
  return errors;
}

export function checkEasJson(e: EasJsonLike): string[] {
  const errors: string[] = [];
  for (const p of ['development', 'preview', 'production']) if (!e.build?.[p]) errors.push(`thiếu build profile "${p}"`);
  if (e.cli?.appVersionSource === 'remote' && !e.build?.production?.autoIncrement) {
    errors.push('appVersionSource=remote nên bật production.autoIncrement');
  }
  if (e.build?.production?.developmentClient) errors.push('production không được là development client');
  return errors;
}
