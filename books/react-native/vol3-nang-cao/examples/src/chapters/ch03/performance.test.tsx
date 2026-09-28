import { render, screen, userEvent } from '@testing-library/react-native';
import type { ProfilerOnRenderCallback } from 'react';
import { RenderCountDemo } from './RenderCountDemo';

test('memo + useCallback: gõ vào ô tìm kiếm không làm MemoRow render lại', async () => {
  const counts: Record<string, number> = { plain: 0, memo: 0 };
  const onRender: ProfilerOnRenderCallback = (id) => {
    counts[id] += 1;
  };
  const user = userEvent.setup();
  await render(<RenderCountDemo onRender={onRender} />);
  const afterMount = { ...counts };

  await user.type(screen.getByLabelText('Gõ để làm cha render lại'), 'abc');

  const plainRenders = counts.plain - afterMount.plain;
  const memoRenders = counts.memo - afterMount.memo;
  expect(plainRenders).toBeGreaterThan(0);
  expect(memoRenders).toBe(0);
});
