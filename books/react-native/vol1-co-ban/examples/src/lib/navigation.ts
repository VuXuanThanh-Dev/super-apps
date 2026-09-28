import type { Href, useRouter } from 'expo-router';

type AppRouter = ReturnType<typeof useRouter>;

// Quay lại nếu có màn hình trước; nếu không (mở thẳng bằng deep link) thì thay bằng `fallback`.
// Lỗi thật đã gặp khi viết test: mở /task/seed-2 trực tiếp rồi bấm Xóa → router.back() báo
// "The action 'GO_BACK' was not handled by any navigator".
export function goBackOr(router: Pick<AppRouter, 'canGoBack' | 'back' | 'replace'>, fallback: Href) {
  if (router.canGoBack()) router.back();
  else router.replace(fallback);
}
