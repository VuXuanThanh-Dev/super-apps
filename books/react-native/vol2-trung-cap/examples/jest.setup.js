// Thiết lập cho Jest, chạy sau khi môi trường test sẵn sàng (trước mỗi file test).

// 1) Reanimated: bật các matcher như toHaveAnimatedStyle và chế độ test.
require('react-native-reanimated').setUpTests();

// 2) AsyncStorage: dùng bản giả (lưu trong bộ nhớ) do chính thư viện cung cấp.
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);
