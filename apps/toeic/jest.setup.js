/* global jest */
// Native modules that do not exist in the Jest (node) environment.
jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(() => Promise.resolve()),
  isSpeakingAsync: jest.fn(() => Promise.resolve(false)),
}));
jest.mock('expo-notifications', () => ({
  SchedulableTriggerInputTypes: { DAILY: 'daily' },
  setNotificationHandler: jest.fn(),
  getPermissionsAsync: jest.fn(() => Promise.resolve({ granted: true, status: 'granted' })),
  requestPermissionsAsync: jest.fn(() => Promise.resolve({ granted: true, status: 'granted' })),
  scheduleNotificationAsync: jest.fn(() => Promise.resolve('notif-1')),
  cancelScheduledNotificationAsync: jest.fn(() => Promise.resolve()),
  cancelAllScheduledNotificationsAsync: jest.fn(() => Promise.resolve()),
  getAllScheduledNotificationsAsync: jest.fn(() => Promise.resolve([])),
  setNotificationChannelAsync: jest.fn(() => Promise.resolve(null)),
  AndroidImportance: { DEFAULT: 3 },
}));

// expo-router: screens call useRouter()/Stack.Screen; tests check the pushed routes.
jest.mock('expo-router', () => {
  const push = jest.fn();
  const back = jest.fn();
  return {
    __mockRouter: { push, back },
    useRouter: () => ({ push, back, replace: jest.fn() }),
    useLocalSearchParams: jest.fn(() => ({})),
    Stack: { Screen: () => null },
    Link: ({ children }) => children,
  };
});
