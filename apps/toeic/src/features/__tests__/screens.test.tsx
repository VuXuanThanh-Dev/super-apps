import { act, fireEvent, screen, waitFor } from '@testing-library/react-native';
import * as Notifications from 'expo-notifications';
import * as Router from 'expo-router';
import { dataIndex, dialogs } from '@/data';
import { DialogScreen } from '@/features/dialogs/DialogScreen';
import { FlashcardScreen } from '@/features/flashcards/FlashcardScreen';
import { newCard } from '@/features/flashcards/sm2';
import { PracticeScreen } from '@/features/practice/PracticeScreen';
import { QuizScreen } from '@/features/quiz/QuizScreen';
import { PassageScreen } from '@/features/reading/PassageScreen';
import { ReadScreen } from '@/features/reading/ReadScreen';
import { SavedScreen } from '@/features/saved/SavedScreen';
import { HomeScreen } from '@/features/stats/HomeScreen';
import { SettingsScreen } from '@/features/theme/SettingsScreen';
import { TopicScreen } from '@/features/vocabulary/TopicScreen';
import { VocabularyScreen } from '@/features/vocabulary/VocabularyScreen';
import { WordScreen } from '@/features/vocabulary/WordScreen';
import { dayNumberFromString, localDayString } from '@/storage/dates';
import { MemoryUserStore } from '@/storage/memoryStore';
import { renderWithApp } from '@/test/render';

const router = (Router as unknown as { __mockRouter: { push: jest.Mock } }).__mockRouter;

beforeEach(() => jest.clearAllMocks());

describe('1. Vocabulary by unit/topic with search', () => {
  it('lists units and opens a unit', async () => {
    await renderWithApp(<VocabularyScreen />);
    await fireEvent.press(await screen.findByTestId('topic-S1'));
    expect(router.push).toHaveBeenCalledWith('/topic/S1');
  });

  it('searches English and Vietnamese', async () => {
    await renderWithApp(<VocabularyScreen />);
    await fireEvent.changeText(await screen.findByTestId('vocab-search'), 'đặt');
    expect(await screen.findByTestId('result-book')).toBeTruthy();
    await fireEvent.changeText(screen.getByTestId('vocab-search'), 'manag');
    await fireEvent.press(await screen.findByTestId('result-manager'));
    const id = dataIndex.wordsByText.get('manager')?.id;
    expect(router.push).toHaveBeenCalledWith(`/word/${id}`);
  });

  it('shows a unit with its word families', async () => {
    await renderWithApp(<TopicScreen code="S1" />);
    expect(await screen.findByTestId('word-management')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('topic-flashcards'));
    expect(router.push).toHaveBeenCalledWith('/flashcards?scope=S1');
  });

  it('shows the full word page', async () => {
    const id = dataIndex.wordsByText.get('delay')?.id ?? '';
    await renderWithApp(<WordScreen id={id} />);
    expect((await screen.findByTestId('popup-word')).props.children).toBe('delay');
    expect(screen.getByText('without delay')).toBeTruthy();
  });
});

describe('2. Flashcards with SM-2', () => {
  it('shows the answer, grades and schedules the card', async () => {
    const { store } = await renderWithApp(<FlashcardScreen scope="S2" today={100} />);
    const first = (await screen.findByTestId('flash-front')).props.children as string;
    await fireEvent.press(screen.getByTestId('flash-show'));
    expect(screen.getByTestId('flash-back')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('grade-good'));
    await waitFor(async () => expect(await store.getCard(first)).toMatchObject({ repetitions: 1, due: 101 }));
    expect((await store.getActivity())[0]?.reviews).toBe(1);
    expect((await screen.findByTestId('flash-front')).props.children).not.toBe(first);
  });

  it('"Again" keeps the card in this session; session ends with a done message', async () => {
    const store = new MemoryUserStore();
    // only one studyable word: make every other S2 word not due
    for (const w of dataIndex.wordsInTopic('S2').slice(1)) {
      await store.saveCard({ ...newCard(w.word, 0), due: 999, repetitions: 3, interval: 30 });
    }
    await renderWithApp(<FlashcardScreen scope="S2" today={100} />, store);
    const word = (await screen.findByTestId('flash-front')).props.children as string;
    await fireEvent.press(screen.getByTestId('flash-show'));
    await fireEvent.press(screen.getByTestId('grade-again'));
    expect((await screen.findByTestId('flash-front')).props.children).toBe(word);
    await fireEvent.press(screen.getByTestId('flash-show'));
    await fireEvent.press(screen.getByTestId('grade-easy'));
    expect(await screen.findByTestId('flash-done')).toBeTruthy();
    expect((await store.getWordStats()).find((s) => s.word === word)).toMatchObject({ correct: 1, wrong: 1 });
  });
});

describe('3. Quizzes', () => {
  it('practice tab links to every quiz type', async () => {
    await renderWithApp(<PracticeScreen />);
    await fireEvent.press(await screen.findByTestId('scope-S1'));
    for (const t of ['meaning', 'blank', 'family', 'collocation', 'listening']) {
      await fireEvent.press(screen.getByTestId(`quiz-${t}`));
      expect(router.push).toHaveBeenLastCalledWith(`/quiz?type=${t}&scope=S1`);
    }
  });

  it.each(['meaning', 'blank', 'family', 'listening'] as const)('%s quiz: answer all and get a score', async (type) => {
    const { store } = await renderWithApp(<QuizScreen type={type} scope="all" seed={11} />);
    await screen.findByTestId('option-0');
    for (let i = 0; i < 20; i++) {
      if (screen.queryByTestId('quiz-score')) break;
      await fireEvent.press(screen.getByTestId('option-0'));
      expect(screen.getByTestId('quiz-feedback')).toBeTruthy();
      await fireEvent.press(screen.getByTestId('quiz-next'));
    }
    expect(await screen.findByTestId('quiz-score')).toBeTruthy();
    expect((await store.getWordStats()).length).toBeGreaterThan(0);
    await waitFor(async () => expect((await store.getActivity())[0]?.quizzes).toBe(1));
  });

  it('collocation matching: pair phrases with meanings and check', async () => {
    await renderWithApp(<QuizScreen type="collocation" scope="all" seed={3} />);
    await screen.findByTestId('left-0');
    let i = 0;
    while (screen.queryByTestId(`left-${i}`)) {
      await fireEvent.press(screen.getByTestId(`left-${i}`));
      await fireEvent.press(screen.getByTestId(`right-${i}`));
      i++;
    }
    await fireEvent.press(screen.getByTestId('match-check'));
    expect(screen.getByTestId('quiz-feedback')).toBeTruthy();
  });

  it('listening quiz speaks the word', async () => {
    const Speech = jest.requireMock('expo-speech') as { speak: jest.Mock };
    await renderWithApp(<QuizScreen type="listening" scope="all" seed={1} />);
    await fireEvent.press(await screen.findByTestId('quiz-play'));
    expect(Speech.speak).toHaveBeenCalled();
  });
});

describe('4. Reading passages', () => {
  it('lists passages and dialogs', async () => {
    await renderWithApp(<ReadScreen />);
    await fireEvent.press(await screen.findByTestId('passage-sp1'));
    expect(router.push).toHaveBeenCalledWith('/passage/sp1');
    await fireEvent.press(screen.getByTestId(`dialog-${dialogs[0]?.id}`));
    expect(router.push).toHaveBeenCalledWith(`/dialog/${dialogs[0]?.id}`);
  });

  it('every word is tappable and questions are scored', async () => {
    const { store } = await renderWithApp(<PassageScreen id="sp1" />);
    await fireEvent.press(await screen.findByText('manages'));
    expect((await screen.findByTestId('popup-word')).props.children).toBe('manage');
    await fireEvent.press(screen.getByTestId('popup-close'));
    await fireEvent.press(screen.getByTestId('q0-o1'));
    await fireEvent.press(screen.getByTestId('q1-o2'));
    expect(await screen.findByTestId('passage-score')).toHaveTextContent('Score: 2 / 2');
    await waitFor(async () => expect((await store.getActivity())[0]?.reads).toBe(1));
  });
});

describe('5. Roleplay dialogs', () => {
  it('hides my lines until I reveal them; words are tappable', async () => {
    const d = dialogs[0];
    if (!d) throw new Error('no dialogs');
    await renderWithApp(<DialogScreen id={d.id} />);
    const me = d.lines[0]?.speaker ?? '';
    await fireEvent.press(await screen.findByTestId(`role-${me}`));
    expect(screen.queryByTestId('line-0')).toBeNull();
    await fireEvent.press(screen.getByTestId('reveal-0'));
    expect(screen.getByTestId('line-0')).toBeTruthy();
    await fireEvent.press(screen.getByText('printer'));
    expect(await screen.findByTestId('word-popup')).toBeTruthy();
  });

  it('has office, meeting, email and phone dialogs', () => {
    expect(new Set(dialogs.map((d) => d.category))).toEqual(new Set(['office', 'meeting', 'email', 'phone']));
  });
});

describe('6. Saved words and daily reminder', () => {
  it('shows saved words and removes them', async () => {
    const store = new MemoryUserStore();
    await store.setSaved('ticket', true);
    await renderWithApp(<SavedScreen />, store);
    expect(await screen.findByTestId('saved-ticket')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('remove-ticket'));
    await waitFor(() => expect(screen.queryByTestId('saved-ticket')).toBeNull());
  });

  it('turns on the daily reminder and changes the hour', async () => {
    await renderWithApp(<SavedScreen />);
    await act(async () => {
      fireEvent(await screen.findByTestId('reminder-switch'), 'valueChange', true);
    });
    await waitFor(() => expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledTimes(1));
    await fireEvent.press(screen.getByTestId('hour-plus'));
    await waitFor(() =>
      expect(Notifications.scheduleNotificationAsync).toHaveBeenLastCalledWith(
        expect.objectContaining({ trigger: { type: 'daily', hour: 21, minute: 0 } }),
      ),
    );
  });
});

describe('7. Progress stats', () => {
  it('shows words learned, streak and weak words', async () => {
    const store = new MemoryUserStore();
    const today = dayNumberFromString('2026-09-28');
    await store.saveCard({ ...newCard('run', 0), repetitions: 2, due: today + 5 });
    await store.saveCard({ ...newCard('book', 0), repetitions: 1, due: today });
    await store.recordActivity('2026-09-27', 'review');
    await store.recordActivity('2026-09-28', 'quiz');
    await store.recordAnswer('delay', false, today);
    await renderWithApp(<HomeScreen today={today} />, store);
    await waitFor(() => expect(screen.getByTestId('stat-learned')).toHaveTextContent('1'));
    expect(screen.getByTestId('stat-streak')).toHaveTextContent('2 🔥');
    expect(screen.getByTestId('stat-due')).toHaveTextContent('1');
    expect(screen.getByTestId('weak-delay')).toBeTruthy();
  });
});

describe('8. Dark mode', () => {
  it('switches theme and saves the choice', async () => {
    const { store } = await renderWithApp(<SettingsScreen />);
    await fireEvent.press(await screen.findByTestId('theme-dark'));
    expect(screen.getByTestId('theme-current')).toHaveTextContent('Current: dark');
    expect(await store.getSetting('theme')).toBe('dark');
    await fireEvent.press(screen.getByTestId('theme-light'));
    expect(screen.getByTestId('theme-current')).toHaveTextContent('Current: light');
  });
});

describe('local day helper', () => {
  it('is used for activity', () => {
    expect(localDayString()).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });
});
