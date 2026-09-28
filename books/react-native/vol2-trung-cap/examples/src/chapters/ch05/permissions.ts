// Luồng xin quyền (permission) — hàm thuần, không phụ thuộc thư viện nào.
// Trạng thái giống expo: 'granted' | 'denied' | 'undetermined', kèm canAskAgain.
export type PermissionStatus = 'granted' | 'denied' | 'undetermined';

export type PermissionAction = 'use' | 'ask' | 'open-settings';

export function nextPermissionAction(status: PermissionStatus, canAskAgain: boolean): PermissionAction {
  if (status === 'granted') return 'use';
  if (status === 'undetermined' || canAskAgain) return 'ask';
  return 'open-settings'; // iOS: đã từ chối → chỉ bật lại được trong Cài đặt
}
