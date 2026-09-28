import { useEffect, useState } from 'react';
import { Text } from 'react-native';

export function formatTime(d: Date): string {
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

// useEffect = ngOnInit + ngOnDestroy gộp lại. Hàm return là phần "dọn dẹp".
export function Clock() {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(id);
  }, []);
  return <Text accessibilityLabel="Đồng hồ" style={{ fontSize: 32, fontVariant: ['tabular-nums'] }}>{formatTime(now)}</Text>;
}
