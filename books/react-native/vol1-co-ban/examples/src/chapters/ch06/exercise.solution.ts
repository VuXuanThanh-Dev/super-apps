// Lời giải bài tập Chương 6: kiểm tra số điện thoại di động Việt Nam.
// Quy tắc đơn giản cho bài tập: 10 chữ số, bắt đầu bằng 0; cho phép khoảng trắng, dấu chấm,
// hoặc tiền tố +84 (sẽ được đổi thành 0).
export function normalizePhone(input: string): string {
  const digits = input.replace(/[\s.-]/g, '');
  return digits.startsWith('+84') ? `0${digits.slice(3)}` : digits;
}

export function validatePhone(input: string): string | undefined {
  if (!input.trim()) return 'Vui lòng nhập số điện thoại';
  const p = normalizePhone(input);
  if (!/^0\d{9}$/.test(p)) return 'Số điện thoại cần 10 chữ số và bắt đầu bằng 0';
  return undefined;
}
