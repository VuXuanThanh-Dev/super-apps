// Chương 4: KHÔNG tin dữ liệu từ bên ngoài app (deep link, push, clipboard).
// Phân tích link "rnbookvol3://note/<id>" một cách an toàn.
//
// Vì sao không dùng `new URL()`? Khi viết test, chúng tôi thấy `new URL('rnbookvol3://note/../../etc')`
// tự "chuẩn hóa" thành host "note" + path "/etc" → dấu hiệu tấn công bị che mất. Ngoài ra cách
// xử lý URL có scheme tùy chỉnh có thể khác nhau giữa môi trường (Node trong Jest và Hermes
// trên máy). Tự phân tích bằng regex + danh sách cho phép (allowlist) thì dễ đoán hơn.
export type DeepLinkTarget = { screen: 'note'; id: string } | { screen: 'home' } | { screen: 'invalid'; reason: string };

const PREFIX = /^rnbookvol3:\/\/(.*)$/;
const ID = /^[a-z0-9-]{1,40}$/;

export function parseDeepLink(raw: string): DeepLinkTarget {
  const m = PREFIX.exec(raw.trim());
  if (!m) return { screen: 'invalid', reason: /^[a-z][a-z0-9+.-]*:/i.test(raw) ? 'Scheme không được phép' : 'URL không hợp lệ' };
  const path = m[1].split(/[?#]/)[0]; // bỏ query/hash
  const parts = path.split('/').filter(Boolean);
  if (parts.length === 0) return { screen: 'home' };
  if (parts[0] === 'note' && parts.length === 2 && ID.test(parts[1])) return { screen: 'note', id: parts[1] };
  return { screen: 'invalid', reason: 'Đường dẫn không hỗ trợ' };
}
