import appJson from '../../../app.json';
import easJson from '../../../eas.json';
import { checkAppConfig, checkEasJson } from './configRules';

describe('Tập 3 — Chương 5: cấu hình build (chạy được trên CI)', () => {
  it('app.json của dự án hợp lệ', () => {
    expect(checkAppConfig(appJson.expo)).toEqual([]);
  });

  it('eas.json của dự án hợp lệ', () => {
    expect(checkEasJson(easJson)).toEqual([]);
  });

  it('phát hiện cấu hình sai', () => {
    expect(checkAppConfig({ version: '1.0', ios: { bundleIdentifier: 'MyApp' }, android: {}, extra: { apiSecret: 'x' } })).toEqual([
      'version phải có dạng x.y.z',
      'ios.bundleIdentifier phải dạng reverse-DNS',
      'android.package phải dạng reverse-DNS',
      'cần scheme cho deep link',
      'app.json có vẻ chứa bí mật',
    ]);
    expect(checkEasJson({ cli: { appVersionSource: 'remote' }, build: { production: { developmentClient: true } } })).toEqual([
      'thiếu build profile "development"',
      'thiếu build profile "preview"',
      'appVersionSource=remote nên bật production.autoIncrement',
      'production không được là development client',
    ]);
  });
});
