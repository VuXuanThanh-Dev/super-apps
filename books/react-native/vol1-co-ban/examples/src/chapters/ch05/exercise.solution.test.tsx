import { fireEvent, render, screen, userEvent } from '@testing-library/react-native';
import { CONTACTS } from './contacts';
import { SortableContacts, sortContacts } from './exercise.solution';

test('sortContacts theo tiếng Việt', () => {
  expect(sortContacts(CONTACTS, 'asc').map((c) => c.name)[0]).toBe('An Nguyễn');
  expect(sortContacts(CONTACTS, 'desc').map((c) => c.name)[0]).toBe('Đặng Minh'); // bảng chữ cái tiếng Việt: Đ đứng sau D
});

test('bấm nút đổi thứ tự, kéo để làm mới gọi load()', async () => {
  const load = jest.fn(async () => [{ id: 'x', name: 'Zen Mới', phone: '0' }]);
  const user = userEvent.setup();
  await render(<SortableContacts load={load} />);
  await user.press(screen.getByRole('button', { name: 'Sắp xếp: A→Z' }));
  expect(screen.getByRole('button', { name: 'Sắp xếp: Z→A' })).toBeOnTheScreen();
  await fireEvent(screen.getByTestId('sortable-list'), 'refresh');
  expect(load).toHaveBeenCalled();
  expect(await screen.findByText('Zen Mới')).toBeOnTheScreen();
});
