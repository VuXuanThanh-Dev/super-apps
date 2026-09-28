import { fireEvent, screen, waitFor } from '@testing-library/react-native';
import * as Speech from 'expo-speech';
import { renderWithApp } from '@/test/render';
import { TappableText } from '../TappableText';

describe('TappableText + WordPopup', () => {
  it('opens the popup with the meaning when a word is tapped', async () => {
    await renderWithApp(<TappableText text="Two companies ran the meeting." />);
    await fireEvent.press(await screen.findByText('companies'));
    expect(await screen.findByTestId('word-popup')).toBeTruthy();
    expect(screen.getByTestId('popup-word')).toHaveTextContent('company');
    expect(screen.getByTestId('popup-vi')).toHaveTextContent('công ty');
    expect(screen.getByText('companies → company')).toBeTruthy();
  });

  it('shows the word family and collocations and can speak', async () => {
    await renderWithApp(<TappableText text="The manager is here." />);
    await fireEvent.press(await screen.findByText('manager'));
    expect(await screen.findByText('management (n)')).toBeTruthy();
    expect(screen.getByText('manage a team')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('popup-speak'));
    expect(Speech.speak).toHaveBeenCalledWith('manager', expect.objectContaining({ language: 'en-US' }));
  });

  it('saves the word to my list', async () => {
    const { store } = await renderWithApp(<TappableText text="Show your ticket." />);
    await fireEvent.press(await screen.findByText('ticket'));
    await fireEvent.press(await screen.findByTestId('popup-save'));
    await waitFor(async () => expect(await store.isSaved('ticket')).toBe(true));
    expect(await screen.findByText('★ Saved (tap to remove)')).toBeTruthy();
  });

  it('shows not found for unknown words', async () => {
    await renderWithApp(<TappableText text="Zzyzx road." />);
    await fireEvent.press(await screen.findByText('Zzyzx'));
    expect(await screen.findByTestId('popup-notfound')).toBeTruthy();
  });

  it('lets you tap a family member and go back', async () => {
    await renderWithApp(<TappableText text="We manage it." />);
    await fireEvent.press(await screen.findByText('manage'));
    await fireEvent.press(await screen.findByText('manager (n)'));
    await waitFor(() => expect(screen.getByTestId('popup-word')).toHaveTextContent('manager'));
    await fireEvent.press(screen.getByLabelText('Back'));
    await waitFor(() => expect(screen.getByTestId('popup-word')).toHaveTextContent('manage'));
  });
});
