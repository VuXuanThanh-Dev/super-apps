import { render, screen, userEvent } from '@testing-library/react-native';
import { FlexPlayground } from './FlexPlayground';
import { DIRECTIONS, nextOption } from './flex';

describe('Chương 4 — Flexbox', () => {
  it('nextOption quay vòng về đầu danh sách', () => {
    expect(nextOption(DIRECTIONS, 'column')).toBe('row');
    expect(nextOption(DIRECTIONS, 'row-reverse')).toBe('column');
  });

  it('mặc định là column; bấm nút đổi sang row', async () => {
    const user = userEvent.setup();
    await render(<FlexPlayground />);
    expect(screen.getByTestId('flex-box')).toHaveStyle({ flexDirection: 'column' });
    await user.press(screen.getByRole('button', { name: 'flexDirection: column' }));
    expect(screen.getByTestId('flex-box')).toHaveStyle({ flexDirection: 'row' });
  });
});
