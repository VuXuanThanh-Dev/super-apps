import { render, screen } from '@testing-library/react-native';
import { ResponsiveGrid, ResponsiveGridView, TwoColumnGrid, columnsFor } from './exercise.solution';

test('TwoColumnGrid dùng row + wrap, mỗi ô rộng 48%', async () => {
  await render(<TwoColumnGrid items={['A', 'B', 'C']} />);
  expect(screen.getByTestId('grid')).toHaveStyle({ flexDirection: 'row', flexWrap: 'wrap' });
  expect(screen.getAllByTestId('cell')).toHaveLength(3);
  expect(screen.getAllByTestId('cell')[0]).toHaveStyle({ width: '48%' });
});

test('Bài 2: columnsFor và ResponsiveGrid trên màn hình iPad', async () => {
  expect(columnsFor(390)).toBe(2);
  expect(columnsFor(1024)).toBe(3);
  await render(<ResponsiveGridView items={['A', 'B', 'C']} width={1024} />);
  expect(screen.getAllByTestId('rcell')[0]).toHaveStyle({ width: '31%' });
  // Bản dùng hook: jest-expo giả lập màn hình iPhone (hẹp hơn 768) → 2 cột
  await render(<ResponsiveGrid items={['A']} />);
  expect(screen.getAllByTestId('rcell')[0]).toHaveStyle({ width: '48%' });
});
