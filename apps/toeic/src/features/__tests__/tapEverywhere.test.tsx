import { fireEvent, screen } from '@testing-library/react-native';
import { dataIndex, dialogs } from '@/data';
import { DialogScreen } from '@/features/dialogs/DialogScreen';
import { TappableText } from '@/features/lookup/TappableText';
import { tokenize } from '@/features/lookup/tokenize';
import { PassageScreen } from '@/features/reading/PassageScreen';
import { renderWithApp } from '@/test/render';

/** For every word token of a text, the rendered <Text> must have an onPress. */
function expectAllWordsTappable(text: string) {
  for (const t of tokenize(text).filter((x) => x.isWord)) {
    const nodes = screen.getAllByText(t.text, { exact: true });
    expect(nodes.some((n) => typeof n.props.onPress === 'function')).toBe(true);
  }
}

describe('tap-to-define on every text screen', () => {
  it.each(dataIndex.passages.map((p) => p.id))('passage %s: every word in text and questions', async (id) => {
    await renderWithApp(<PassageScreen id={id} />);
    const p = dataIndex.passages.find((x) => x.id === id);
    await screen.findByTestId('passage-text');
    expectAllWordsTappable(p?.text ?? '');
    for (const q of p?.questions ?? []) {
      expectAllWordsTappable(q.question);
      q.options.forEach((o) => expectAllWordsTappable(o));
    }
  });

  it.each(dialogs.map((d) => d.id))('dialog %s: every word of every line', async (id) => {
    await renderWithApp(<DialogScreen id={id} />);
    const d = dialogs.find((x) => x.id === id);
    await screen.findByTestId('line-0');
    expectAllWordsTappable(d?.setting ?? '');
    for (const l of d?.lines ?? []) expectAllWordsTappable(l.text);
  });

  it('words inside the popup (definition, example, collocation examples) are tappable too', async () => {
    await renderWithApp(<TappableText text="book" />);
    await fireEvent.press(await screen.findByText('book'));
    const w = dataIndex.wordsByText.get('book');
    if (!w) throw new Error('missing word');
    expectAllWordsTappable(w.definition ?? '');
    expectAllWordsTappable(w.example ?? '');
    for (const c of dataIndex.collocationsForWord(w)) expectAllWordsTappable(c.example);
  });
});
