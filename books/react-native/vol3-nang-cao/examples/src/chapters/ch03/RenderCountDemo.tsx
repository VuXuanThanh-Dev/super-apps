import { memo, Profiler, useCallback, useState, type ProfilerOnRenderCallback } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';

// Chương 3: đo số lần render bằng <Profiler> của React.
// <Profiler> đặt BÊN TRONG Row: chỉ khi Row thật sự render thì onRender mới được gọi.
// Row thường: render lại mỗi khi cha render. MemoRow: chỉ khi props đổi.
interface RowProps {
  id: string;
  label: string;
  onPress: () => void;
  onRender: ProfilerOnRenderCallback;
}

function Row({ id, label, onPress, onRender }: RowProps) {
  return (
    <Profiler id={id} onRender={onRender}>
      <Pressable onPress={onPress}>
        <Text>{label}</Text>
      </Pressable>
    </Profiler>
  );
}
const MemoRow = memo(Row);

const noop: ProfilerOnRenderCallback = () => {};

export function RenderCountDemo({
  onRender = noop,
  inlineCallback = false,
}: {
  onRender?: ProfilerOnRenderCallback;
  inlineCallback?: boolean; // bài tập: truyền hàm tạo mới mỗi lần render → memo mất tác dụng
}) {
  const [query, setQuery] = useState('');
  const [taps, setTaps] = useState(0);
  const handlePress = useCallback(() => setTaps((t) => t + 1), []); // hàm ổn định giữa các lần render

  return (
    <View style={{ padding: 16, gap: 8 }}>
      <TextInput accessibilityLabel="Gõ để làm cha render lại" value={query} onChangeText={setQuery} />
      <Text>Số lần bấm: {taps}</Text>
      <Row id="plain" label="Row thường" onPress={handlePress} onRender={onRender} />
      <MemoRow
        id="memo"
        label="Row có memo"
        onPress={inlineCallback ? () => setTaps((t) => t + 1) : handlePress}
        onRender={onRender}
      />
    </View>
  );
}
