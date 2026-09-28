import { render, screen, userEvent } from '@testing-library/react-native';
import { reverseText, statsInJs } from '../../../modules/text-stats';
import { TextStatsDemo } from './TextStatsDemo';

describe('Tập 3 — Chương 2: native module', () => {
  it('bản JS đếm từ và ký tự theo code point (emoji = 1)', () => {
    expect(statsInJs('Xin chào 👋')).toEqual({ words: 3, characters: 10 });
    expect(statsInJs('   ')).toEqual({ words: 0, characters: 3 });
    expect(statsInJs('một\nhai\tba')).toEqual({ words: 3, characters: 10 });
  });

  it('bài tập: reverseText không làm vỡ emoji (bản JS)', () => {
    expect(reverseText('ab👋')).toBe('👋ba');
    expect('ab👋'.split('').reverse().join('')).not.toBe('👋ba'); // cách sai: tách theo UTF-16
  });

  it('không có module native (như Expo Go) → dùng JS', async () => {
    const user = userEvent.setup();
    await render(<TextStatsDemo />);
    expect(screen.getByText('isNativeAvailable(): false')).toBeOnTheScreen();
    await user.clear(screen.getByLabelText('Văn bản'));
    await user.type(screen.getByLabelText('Văn bản'), 'hai từ');
    expect(screen.getByLabelText('Thống kê')).toHaveTextContent('2 từ · 6 ký tự');
  });

  it('có module native (giả lập development build) → gọi native', async () => {
    jest.resetModules();
    const stats = jest.fn(() => ({ words: 42, characters: 99 }));
    jest.doMock('expo', () => ({
      ...jest.requireActual('expo'),
      requireOptionalNativeModule: () => ({ platform: 'ios', stats }),
    }));
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const mod = require('../../../modules/text-stats') as typeof import('../../../modules/text-stats');
    expect(mod.isNativeAvailable()).toBe(true);
    expect(mod.textStats('abc')).toEqual({ words: 42, characters: 99, source: 'native' });
    expect(stats).toHaveBeenCalledWith('abc');
  });
});
