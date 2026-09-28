import { create } from 'zustand';

// Chương 1 (Tập 2): so sánh useReducer (state cục bộ) với Zustand (state toàn cục).
export interface CartItem {
  id: string;
  name: string;
  price: number; // đơn vị: đồng
  qty: number;
}

interface CartState {
  items: CartItem[];
  add: (item: Omit<CartItem, 'qty'>) => void;
  remove: (id: string) => void; // lời giải bài tập
  clear: () => void;
}

export const useCart = create<CartState>()((set) => ({
  items: [],
  add: (item) =>
    set((s) => {
      const found = s.items.find((i) => i.id === item.id);
      return {
        items: found
          ? s.items.map((i) => (i.id === item.id ? { ...i, qty: i.qty + 1 } : i))
          : [...s.items, { ...item, qty: 1 }],
      };
    }),
  remove: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),
  clear: () => set({ items: [] }),
}));

// Selector thuần (lời giải bài tập): tính tổng tiền — test được không cần React.
export const selectTotal = (s: Pick<CartState, 'items'>) => s.items.reduce((sum, i) => sum + i.price * i.qty, 0);
export const selectCount = (s: Pick<CartState, 'items'>) => s.items.reduce((n, i) => n + i.qty, 0);

export function formatVnd(amount: number): string {
  return `${amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')} ₫`;
}
