import { render, screen, userEvent } from '@testing-library/react-native';
import { useState } from 'react';
import { Pressable, Text } from 'react-native';
import { ErrorBoundary } from '@/monitoring/ErrorBoundary';
import { createDedupeTransport } from '@/monitoring/dedupe';
import { createLogger, logger, type ErrorReport } from '@/monitoring/logger';

function Bomb({ explode }: { explode: boolean }) {
  if (explode) throw new Error('Nổ khi render!');
  return <Text>Bình thường</Text>;
}

function Harness() {
  const [explode, setExplode] = useState(false);
  return (
    <>
      <Pressable accessibilityRole="button" onPress={() => setExplode(true)}>
        <Text>Gây lỗi</Text>
      </Pressable>
      <ErrorBoundary>
        <Bomb explode={explode} />
      </ErrorBoundary>
    </>
  );
}

describe('Tập 3 — Chương 7: monitoring', () => {
  it('breadcrumbs: giữ 30 mục mới nhất và ẩn dữ liệu nhạy cảm', () => {
    const log = createLogger(() => 1);
    for (let i = 0; i < 35; i++) log.addBreadcrumb('info', `b${i}`);
    log.addBreadcrumb('warn', 'login', { pin: '2580', attempts: 2 });
    expect(log.breadcrumbs()).toHaveLength(30);
    expect(log.breadcrumbs().at(-1)).toEqual({ at: 1, level: 'warn', message: 'login', data: { pin: '[ẩn]', attempts: 2 } });
  });

  it('reportError gửi tới mọi transport; transport lỗi không làm hỏng app', () => {
    const log = createLogger();
    const received: ErrorReport[] = [];
    log.addTransport(() => {
      throw new Error('transport hỏng');
    });
    log.addTransport((r) => received.push(r));
    log.addBreadcrumb('info', 'mở màn hình');
    log.reportError('chuỗi lỗi');
    expect(received[0].error.message).toBe('chuỗi lỗi');
    expect(received[0].breadcrumbs.map((b) => b.message)).toEqual(['mở màn hình']);
  });

  it('ErrorBoundary: bắt lỗi render, hiện màn hình dự phòng và báo cáo lỗi', async () => {
    const reports: ErrorReport[] = [];
    const remove = logger.addTransport((r) => reports.push(r));
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {}); // React in lỗi ra console
    const user = userEvent.setup();
    await render(<Harness />);
    expect(screen.getByText('Bình thường')).toBeOnTheScreen();

    await user.press(screen.getByRole('button', { name: 'Gây lỗi' }));

    expect(screen.getByRole('alert')).toHaveTextContent(/Đã có lỗi xảy ra/);
    expect(screen.getByText('Nổ khi render!')).toBeOnTheScreen();
    expect(reports).toHaveLength(1);
    expect(reports[0].error.message).toBe('Nổ khi render!');
    expect(typeof reports[0].context?.componentStack).toBe('string');
    consoleSpy.mockRestore();
    remove();
  });
});

test('bài tập: createDedupeTransport bỏ lỗi trùng trong 60 giây', () => {
  let t = 0;
  const inner = jest.fn();
  const dedupe = createDedupeTransport(inner, 60_000, () => t);
  const report = (msg: string) => ({ error: new Error(msg), breadcrumbs: [] });
  dedupe(report('A'));
  t = 30_000;
  dedupe(report('A')); // trùng, bỏ
  dedupe(report('B')); // khác, gửi
  t = 61_000;
  dedupe(report('A')); // hết cửa sổ, gửi lại
  expect(inner.mock.calls.map((c) => c[0].error.message)).toEqual(['A', 'B', 'A']);
});
