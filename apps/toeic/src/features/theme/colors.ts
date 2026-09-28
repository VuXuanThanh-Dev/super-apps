export interface Palette {
  background: string;
  card: string;
  text: string;
  muted: string;
  border: string;
  primary: string;
  primaryText: string;
  accent: string;
  success: string;
  danger: string;
  highlight: string;
}

export const lightPalette: Palette = {
  background: '#F6F7F9',
  card: '#FFFFFF',
  text: '#1C2230',
  muted: '#5E6675',
  border: '#DDE1E7',
  primary: '#0A6E5C',
  primaryText: '#FFFFFF',
  accent: '#B5482A',
  success: '#1E8E3E',
  danger: '#C62828',
  highlight: '#FFF3C4',
};

export const darkPalette: Palette = {
  background: '#101318',
  card: '#1A1F27',
  text: '#E8EAED',
  muted: '#A0A7B4',
  border: '#2C333D',
  primary: '#3CC4A7',
  primaryText: '#0B1F1A',
  accent: '#F08A6C',
  success: '#5BD17A',
  danger: '#FF6B6B',
  highlight: '#4A3F12',
};

export type ThemePreference = 'system' | 'light' | 'dark';

export function resolvePalette(pref: ThemePreference, system: string | null | undefined): {
  scheme: 'light' | 'dark';
  palette: Palette;
} {
  const scheme = pref === 'system' ? (system === 'dark' ? 'dark' : 'light') : pref;
  return { scheme, palette: scheme === 'dark' ? darkPalette : lightPalette };
}
