import { normalizePhone, validatePhone } from './exercise.solution';

test.each([
  ['0901 234 567', undefined],
  ['+84 901 234 567', undefined],
  ['090.123.4567', undefined],
  ['12345', 'Số điện thoại cần 10 chữ số và bắt đầu bằng 0'],
  ['', 'Vui lòng nhập số điện thoại'],
])('validatePhone(%p) → %p', (input, expected) => {
  expect(validatePhone(input)).toBe(expected);
});

test('normalizePhone đổi +84 thành 0', () => {
  expect(normalizePhone('+84901234567')).toBe('0901234567');
});
