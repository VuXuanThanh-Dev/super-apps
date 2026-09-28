import { Pressable, Text, View } from 'react-native';

// Angular:  @Input() value; @Output() valueChange = new EventEmitter<number>();
// React:    props `value` + callback `onChange` (dữ liệu đi xuống, sự kiện đi lên).
interface RatingStarsProps {
  value: number;
  max?: number;
  onChange: (value: number) => void;
}

export function RatingStars({ value, max = 5, onChange }: RatingStarsProps) {
  return (
    <View style={{ flexDirection: 'row' }}>
      {Array.from({ length: max }, (_, i) => i + 1).map((n) => (
        <Pressable
          key={n}
          accessibilityRole="button"
          accessibilityLabel={`${n} sao`}
          accessibilityState={{ selected: n <= value }}
          onPress={() => onChange(n)}
        >
          <Text style={{ fontSize: 32 }}>{n <= value ? '★' : '☆'}</Text>
        </Pressable>
      ))}
    </View>
  );
}
