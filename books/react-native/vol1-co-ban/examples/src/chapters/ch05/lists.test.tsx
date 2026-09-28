import { render, screen, userEvent } from '@testing-library/react-native';
import { ContactList, ContactSections } from './ContactList';
import { CONTACTS, groupByLetter, removeDiacritics, searchContacts } from './contacts';

describe('Chương 5 — danh sách', () => {
  it('removeDiacritics xử lý cả chữ đ/Đ', () => {
    expect(removeDiacritics('Đặng Ánh ư ơ')).toBe('Dang Anh u o');
  });

  it('searchContacts tìm không dấu và theo số điện thoại', () => {
    expect(searchContacts(CONTACTS, 'anh').map((c) => c.name)).toEqual(['Ánh Lê']);
    expect(searchContacts(CONTACTS, '0903').map((c) => c.name)).toEqual(['Bình Trần']);
  });

  it('groupByLetter gom "An" và "Ánh" vào nhóm A', () => {
    const sections = groupByLetter(CONTACTS);
    expect(sections.map((s) => s.title)).toEqual(['A', 'B', 'D']);
    expect(sections[0].data.map((c) => c.name)).toEqual(['An Nguyễn', 'Ánh Lê']);
  });

  it('ContactList lọc khi gõ', async () => {
    const user = userEvent.setup();
    await render(<ContactList />);
    await user.type(screen.getByLabelText('Tìm liên hệ'), 'dung');
    expect(screen.getByText('Dũng Phạm')).toBeOnTheScreen();
    expect(screen.queryByText('An Nguyễn')).not.toBeOnTheScreen();
  });

  it('Bài tập 2: phân biệt "Danh bạ trống" và "Không tìm thấy"', async () => {
    const user = userEvent.setup();
    await render(<ContactList contacts={[]} />);
    expect(screen.getByText('Danh bạ trống')).toBeOnTheScreen();
    await render(<ContactList />);
    await user.type(screen.getByLabelText('Tìm liên hệ'), 'xyz');
    expect(screen.getByText('Không tìm thấy')).toBeOnTheScreen();
  });

  it('ContactSections hiện tiêu đề nhóm', async () => {
    await render(<ContactSections />);
    expect(screen.getAllByRole('header').map((h) => h.props.children)).toEqual(['A', 'B', 'D']);
  });
});
