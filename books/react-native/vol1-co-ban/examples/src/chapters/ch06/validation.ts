export interface SignUpValues {
  email: string;
  password: string;
  confirm: string;
  acceptTerms: boolean;
}

export type SignUpErrors = Partial<Record<keyof SignUpValues, string>>;

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Giống Validators.required / Validators.email / Validators.minLength của Angular,
// nhưng chỉ là một hàm thuần trả về object lỗi.
export function validateSignUp(v: SignUpValues): SignUpErrors {
  const e: SignUpErrors = {};
  if (!v.email.trim()) e.email = 'Vui lòng nhập email';
  else if (!EMAIL_RE.test(v.email.trim())) e.email = 'Email không hợp lệ';
  if (v.password.length < 8) e.password = 'Mật khẩu cần ít nhất 8 ký tự';
  else if (!/\d/.test(v.password)) e.password = 'Mật khẩu cần ít nhất 1 chữ số';
  if (v.confirm !== v.password) e.confirm = 'Mật khẩu nhập lại không khớp';
  if (!v.acceptTerms) e.acceptTerms = 'Bạn cần đồng ý điều khoản';
  return e;
}

export const isValid = (e: SignUpErrors) => Object.keys(e).length === 0;
