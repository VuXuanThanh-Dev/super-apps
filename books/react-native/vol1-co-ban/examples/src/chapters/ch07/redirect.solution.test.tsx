import { screen } from '@testing-library/react-native';
import { Redirect, useLocalSearchParams } from 'expo-router';
import { renderRouter } from 'expo-router/testing-library';
import { Text } from 'react-native';

// Lời giải Bài 2 Chương 7: id không tồn tại → <Redirect href="/" />.
// Dùng "mock routes" (object thay cho thư mục) để test riêng ý tưởng này.
const KNOWN = ['a1'];

function Detail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  if (!KNOWN.includes(id)) return <Redirect href="/" />;
  return <Text>Chi tiết {id}</Text>;
}

test('deep link tới id không tồn tại thì quay về trang chủ', async () => {
  const view = renderRouter(
    { index: () => <Text>Trang chủ</Text>, 'task/[id]': Detail },
    { initialUrl: '/task/khong-co' },
  );
  await view;
  expect(await screen.findByText('Trang chủ')).toBeOnTheScreen();
  expect(view.getPathname()).toBe('/');
});

test('id hợp lệ thì ở lại màn hình chi tiết', async () => {
  const view = renderRouter(
    { index: () => <Text>Trang chủ</Text>, 'task/[id]': Detail },
    { initialUrl: '/task/a1' },
  );
  await view;
  expect(await screen.findByText('Chi tiết a1')).toBeOnTheScreen();
  expect(view.getPathname()).toBe('/task/a1');
});
