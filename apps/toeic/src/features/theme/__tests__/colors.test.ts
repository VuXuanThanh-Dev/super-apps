import { darkPalette, lightPalette, resolvePalette } from '../colors';

describe('dark mode palette', () => {
  it('follows the system when preference is system', () => {
    expect(resolvePalette('system', 'dark')).toEqual({ scheme: 'dark', palette: darkPalette });
    expect(resolvePalette('system', 'light').scheme).toBe('light');
    expect(resolvePalette('system', null).scheme).toBe('light');
  });
  it('forces light or dark', () => {
    expect(resolvePalette('dark', 'light').palette).toBe(darkPalette);
    expect(resolvePalette('light', 'dark').palette).toBe(lightPalette);
  });
  it('dark palette uses a dark background and light text', () => {
    expect(darkPalette.background).not.toBe(lightPalette.background);
    expect(parseInt(darkPalette.background.slice(1, 3), 16)).toBeLessThan(0x40);
    expect(parseInt(darkPalette.text.slice(1, 3), 16)).toBeGreaterThan(0xc0);
  });
});
