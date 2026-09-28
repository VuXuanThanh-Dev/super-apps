// Lời giải bài tập Chương 5: định dạng tọa độ kiểu Việt Nam, dấu phẩy thập phân.
// 10.7769, 106.7009 → "10,7769° B, 106,7009° Đ"
export function formatCoords(latitude: number, longitude: number, digits = 4): string {
  const fmt = (n: number) => Math.abs(n).toFixed(digits).replace('.', ',');
  const ns = latitude >= 0 ? 'B' : 'N'; // Bắc / Nam
  const ew = longitude >= 0 ? 'Đ' : 'T'; // Đông / Tây
  return `${fmt(latitude)}° ${ns}, ${fmt(longitude)}° ${ew}`;
}
