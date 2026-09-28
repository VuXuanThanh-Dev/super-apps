import { render, screen, userEvent } from '@testing-library/react-native';
import { CartDemo } from './CartDemo';
import { formatVnd, selectCount, selectTotal, useCart } from './cartStore';
import { counterReducer } from './counterReducer';

beforeEach(() => useCart.getState().clear());

describe('Tập 2 — Chương 1: quản lý state', () => {
  it('counterReducer không cho số âm', () => {
    expect(counterReducer(0, { type: 'dec' })).toBe(0);
    expect(counterReducer(2, { type: 'inc' })).toBe(3);
  });

  it('store Zustand: thêm cùng món thì tăng qty', () => {
    const { add } = useCart.getState();
    add({ id: 'a', name: 'A', price: 10000 });
    add({ id: 'a', name: 'A', price: 10000 });
    add({ id: 'b', name: 'B', price: 5000 });
    const state = useCart.getState();
    expect(selectCount(state)).toBe(3);
    expect(selectTotal(state)).toBe(25000);
  });

  it('bài tập: remove và formatVnd', () => {
    useCart.getState().add({ id: 'a', name: 'A', price: 1000 });
    useCart.getState().remove('a');
    expect(useCart.getState().items).toEqual([]);
    expect(formatVnd(1234567)).toBe('1.234.567 ₫');
  });

  it('nhiều component đọc cùng store và cùng cập nhật', async () => {
    const user = userEvent.setup();
    await render(<CartDemo />);
    await user.press(screen.getByRole('button', { name: /Thêm Cà phê/ }));
    await user.press(screen.getByRole('button', { name: /Thêm Bánh mì/ }));
    expect(screen.getByLabelText('Số món')).toHaveTextContent('🛒 2');
    expect(screen.getByLabelText('Tổng tiền')).toHaveTextContent('Tổng: 54.000 ₫');
  });
});
