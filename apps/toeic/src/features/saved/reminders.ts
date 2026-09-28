import * as Notifications from 'expo-notifications';
import type { UserStore } from '@/storage/types';

export const REMINDER_KEY = 'reminder';

export interface ReminderSetting {
  enabled: boolean;
  hour: number;
  minute: number;
  notificationId: string | null;
}

export const DEFAULT_REMINDER: ReminderSetting = { enabled: false, hour: 20, minute: 0, notificationId: null };

export async function loadReminder(store: UserStore): Promise<ReminderSetting> {
  const raw = await store.getSetting(REMINDER_KEY);
  if (!raw) return DEFAULT_REMINDER;
  try {
    return { ...DEFAULT_REMINDER, ...(JSON.parse(raw) as Partial<ReminderSetting>) };
  } catch {
    return DEFAULT_REMINDER;
  }
}

export function reminderBody(savedCount: number, dueCount: number): string {
  if (dueCount > 0) return `You have ${dueCount} cards to review. Ôn ${dueCount} thẻ hôm nay nhé!`;
  if (savedCount > 0) return `Review your ${savedCount} saved words. Ôn lại từ đã lưu nhé!`;
  return 'Time for 10 minutes of TOEIC words. Học 10 phút nhé!';
}

/** Turn the daily local reminder on (asks permission) or off. Returns the new setting. */
export async function applyReminder(
  store: UserStore,
  next: { enabled: boolean; hour: number; minute: number },
  body: string,
): Promise<ReminderSetting> {
  const current = await loadReminder(store);
  if (current.notificationId) {
    await Notifications.cancelScheduledNotificationAsync(current.notificationId);
  }
  let notificationId: string | null = null;
  let enabled = next.enabled;
  if (next.enabled) {
    let perm = await Notifications.getPermissionsAsync();
    if (!perm.granted) perm = await Notifications.requestPermissionsAsync();
    if (perm.granted) {
      notificationId = await Notifications.scheduleNotificationAsync({
        content: { title: 'TOEIC 900 · Daily review', body },
        trigger: { type: Notifications.SchedulableTriggerInputTypes.DAILY, hour: next.hour, minute: next.minute },
      });
    } else {
      enabled = false;
    }
  }
  const setting: ReminderSetting = { enabled, hour: next.hour, minute: next.minute, notificationId };
  await store.setSetting(REMINDER_KEY, JSON.stringify(setting));
  return setting;
}

export function formatTime(hour: number, minute: number): string {
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
}
