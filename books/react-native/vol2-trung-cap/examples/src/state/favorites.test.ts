import AsyncStorage from '@react-native-async-storage/async-storage';
import { useFavorites } from './favorites';

beforeEach(async () => {
  await AsyncStorage.clear();
  useFavorites.getState().clear(); // store Zustand dùng được ngoài React: gọi thẳng getState()
});

describe('useFavorites (Zustand + persist)', () => {
  it('toggle thêm rồi bỏ một id', () => {
    useFavorites.getState().toggle(2);
    expect(useFavorites.getState().ids).toEqual([2]);
    useFavorites.getState().toggle(2);
    expect(useFavorites.getState().ids).toEqual([]);
  });

  it('tự lưu xuống AsyncStorage dưới khóa favorites-v1', async () => {
    useFavorites.getState().toggle(7);
    const raw = await AsyncStorage.getItem('favorites-v1');
    expect(JSON.parse(raw ?? '{}')).toMatchObject({ state: { ids: [7] } });
  });
});
