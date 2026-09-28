// Bảng màu và khoảng cách dùng chung cho cả app (giống một file SCSS variables).
export const colors = {
  primary: '#2563eb',
  danger: '#dc2626',
  success: '#16a34a',
  text: '#111827',
  muted: '#6b7280',
  border: '#e5e7eb',
  background: '#f9fafb',
  card: '#ffffff',
} as const;

export const spacing = { xs: 4, sm: 8, md: 12, lg: 16, xl: 24 } as const;
