import * as Notifications from 'expo-notifications';
import { MemoryUserStore } from '@/storage/memoryStore';
import { applyReminder, formatTime, loadReminder, reminderBody } from '../reminders';

const N = Notifications as jest.Mocked<typeof Notifications>;

describe('daily reminder (local notification)', () => {
  beforeEach(() => jest.clearAllMocks());

  it('schedules a DAILY notification at the chosen time and stores the id', async () => {
    const store = new MemoryUserStore();
    const r = await applyReminder(store, { enabled: true, hour: 7, minute: 30 }, 'body');
    expect(N.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: { title: 'TOEIC 900 · Daily review', body: 'body' },
      trigger: { type: 'daily', hour: 7, minute: 30 },
    });
    expect(r).toEqual({ enabled: true, hour: 7, minute: 30, notificationId: 'notif-1' });
    expect(await loadReminder(store)).toEqual(r);
  });

  it('cancels the old notification when turned off or changed', async () => {
    const store = new MemoryUserStore();
    await applyReminder(store, { enabled: true, hour: 20, minute: 0 }, 'b');
    const off = await applyReminder(store, { enabled: false, hour: 20, minute: 0 }, 'b');
    expect(N.cancelScheduledNotificationAsync).toHaveBeenCalledWith('notif-1');
    expect(off.enabled).toBe(false);
    expect(off.notificationId).toBeNull();
  });

  it('stays off when permission is denied', async () => {
    N.getPermissionsAsync.mockResolvedValueOnce({ granted: false } as never);
    N.requestPermissionsAsync.mockResolvedValueOnce({ granted: false } as never);
    const r = await applyReminder(new MemoryUserStore(), { enabled: true, hour: 9, minute: 0 }, 'b');
    expect(r.enabled).toBe(false);
    expect(N.scheduleNotificationAsync).not.toHaveBeenCalled();
  });

  it('writes a helpful message and formats time', () => {
    expect(reminderBody(3, 5)).toContain('5 cards');
    expect(reminderBody(3, 0)).toContain('3 saved');
    expect(formatTime(7, 5)).toBe('07:05');
  });
});
