import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

// Store toàn cục với Zustand — giống một Angular service có state (signal) dùng chung.
// `persist` tự lưu xuống AsyncStorage và đọc lại khi mở app.
interface FavoritesState {
  ids: number[];
  toggle: (id: number) => void;
  clear: () => void;
}

export const useFavorites = create<FavoritesState>()(
  persist(
    (set) => ({
      ids: [],
      toggle: (id) =>
        set((s) => ({ ids: s.ids.includes(id) ? s.ids.filter((x) => x !== id) : [...s.ids, id] })),
      clear: () => set({ ids: [] }),
    }),
    {
      name: 'favorites-v1', // khóa trong AsyncStorage
      storage: createJSONStorage(() => AsyncStorage),
    },
  ),
);

// Selector: component chỉ render lại khi phần nó chọn thay đổi (giống computed()).
export const useIsFavorite = (id: number) => useFavorites((s) => s.ids.includes(id));
export const useFavoriteCount = () => useFavorites((s) => s.ids.length);
