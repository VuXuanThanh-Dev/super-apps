// Thiết lập Jest cho Tập 3.
//
// FlashList v2 cần đo kích thước view (không có trong môi trường test) → giả lập phép đo.
// Lưu ý: file `@shopify/flash-list/jestSetup` của bản 2.0.2 thay FlashList bằng
// `RecyclerView` lấy từ gói — nhưng gói KHÔNG export `RecyclerView`, nên FlashList thành
// `undefined` ("Element type is invalid"). Vì vậy ta chỉ giả lập phần đo layout.
jest.mock('@shopify/flash-list/dist/recyclerview/utils/measureLayout', () => {
  const actual = jest.requireActual('@shopify/flash-list/dist/recyclerview/utils/measureLayout');
  const screen = { x: 0, y: 0, width: 400, height: 900 };
  return {
    ...actual,
    measureParentSize: jest.fn(() => screen),
    measureFirstChildLayout: jest.fn(() => screen),
    measureItemLayout: jest.fn(() => ({ x: 0, y: 0, width: 400, height: 80 })),
  };
});
