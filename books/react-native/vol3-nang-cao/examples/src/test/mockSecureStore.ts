// Bản giả expo-secure-store lưu trong bộ nhớ (dùng với jest.mock).
const store = new Map<string, string>();

export const secureStoreMock = {
  WHEN_UNLOCKED_THIS_DEVICE_ONLY: 'WHEN_UNLOCKED_THIS_DEVICE_ONLY',
  getItemAsync: jest.fn(async (k: string) => store.get(k) ?? null),
  setItemAsync: jest.fn(async (k: string, v: string) => {
    store.set(k, v);
  }),
  deleteItemAsync: jest.fn(async (k: string) => {
    store.delete(k);
  }),
  __clear: () => store.clear(),
};
