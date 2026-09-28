import { act, render, renderHook, screen, userEvent } from '@testing-library/react-native';
import { Text } from 'react-native';
import { AngularMappingDemo, cartCount } from './AngularMappingDemo';
import { GreetingProvider, formalGreeting, useGreeting } from './GreetingService';
import { RatingStars } from './RatingStars';
import { createSignal } from './signal';
import { useDebouncedValue } from './useDebouncedValue';

describe('Angular → React Native', () => {
  it('RatingStars: props đi xuống, callback đi lên (như @Input/@Output)', async () => {
    const onChange = jest.fn();
    const user = userEvent.setup();
    await render(<RatingStars value={2} onChange={onChange} />);
    await user.press(screen.getByRole('button', { name: '4 sao' }));
    expect(onChange).toHaveBeenCalledWith(4);
  });

  it('createSignal: set/update/subscribe, bỏ qua giá trị không đổi', () => {
    const s = createSignal(1);
    const listener = jest.fn();
    const unsubscribe = s.subscribe(listener);
    s.set(1);
    s.update((v) => v + 1);
    expect(s.get()).toBe(2);
    expect(listener).toHaveBeenCalledTimes(1);
    unsubscribe();
    s.set(5);
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it('Context thay implementation giống providers: [{ provide, useClass }]', async () => {
    function Probe() {
      return <Text>{useGreeting().greet('Nobin')}</Text>;
    }
    await render(
      <GreetingProvider service={formalGreeting}>
        <Probe />
      </GreetingProvider>,
    );
    expect(screen.getByText('Kính chào anh/chị Nobin.')).toBeOnTheScreen();
  });

  it('useDebouncedValue chỉ cập nhật sau 300ms (debounceTime)', async () => {
    jest.useFakeTimers();
    const { result, rerender } = await renderHook(({ v }: { v: string }) => useDebouncedValue(v, 300), {
      initialProps: { v: 'a' },
    });
    await rerender({ v: 'ab' });
    expect(result.current).toBe('a');
    await act(async () => {
      jest.advanceTimersByTime(300);
    });
    expect(result.current).toBe('ab');
    jest.useRealTimers();
  });

  it('Demo: bấm "Thêm vào giỏ" làm badge cập nhật', async () => {
    cartCount.set(0);
    const user = userEvent.setup();
    await render(<AngularMappingDemo />);
    await user.press(screen.getByRole('button', { name: 'Thêm vào giỏ' }));
    expect(screen.getByLabelText('Số món trong giỏ')).toHaveTextContent('🛒 1');
  });
});
