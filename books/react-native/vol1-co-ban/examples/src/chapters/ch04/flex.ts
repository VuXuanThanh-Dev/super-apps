import type { FlexStyle } from 'react-native';

export const DIRECTIONS = ['column', 'row', 'column-reverse', 'row-reverse'] as const;
export const JUSTIFY = ['flex-start', 'center', 'flex-end', 'space-between', 'space-around', 'space-evenly'] as const;
export const ALIGN = ['stretch', 'flex-start', 'center', 'flex-end'] as const;

// Lấy phần tử tiếp theo trong danh sách (quay vòng). Hàm thuần → dễ test.
export function nextOption<T>(options: readonly T[], current: T): T {
  const i = options.indexOf(current);
  return options[(i + 1) % options.length];
}

export interface FlexState {
  flexDirection: (typeof DIRECTIONS)[number];
  justifyContent: (typeof JUSTIFY)[number];
  alignItems: (typeof ALIGN)[number];
}

export function toStyle(s: FlexState): FlexStyle {
  return { flexDirection: s.flexDirection, justifyContent: s.justifyContent, alignItems: s.alignItems };
}
