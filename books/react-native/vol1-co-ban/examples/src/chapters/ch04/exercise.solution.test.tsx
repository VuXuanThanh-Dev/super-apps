import { render, screen } from '@testing-library/react-native';
import { TwoColumnGrid } from './exercise.solution';

test('TwoColumnGrid dùng row + wrap, mỗi ô rộng 48%', async () => {
  await render(<TwoColumnGrid items={['A', 'B', 'C']} />);
  expect(screen.getByTestId('grid')).toHaveStyle({ flexDirection: 'row', flexWrap: 'wrap' });
  expect(screen.getAllByTestId('cell')).toHaveLength(3);
  expect(screen.getAllByTestId('cell')[0]).toHaveStyle({ width: '48%' });
});
