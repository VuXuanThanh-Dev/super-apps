import { useState } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { GreetingProvider, formalGreeting, useGreeting } from './GreetingService';
import { RatingStars } from './RatingStars';
import { createSignal, useSignal } from './signal';
import { useDebouncedValue } from './useDebouncedValue';

export const cartCount = createSignal(0); // sống ngoài component, như một service singleton

function CartBadge() {
  const count = useSignal(cartCount);
  return <Text accessibilityLabel="Số món trong giỏ">🛒 {count}</Text>;
}

function Greeter({ name }: { name: string }) {
  const greeting = useGreeting();
  return <Text>{greeting.greet(name)}</Text>;
}

export function AngularMappingDemo() {
  const [rating, setRating] = useState(3);
  const [query, setQuery] = useState('');
  const debounced = useDebouncedValue(query, 300);

  return (
    <View style={{ padding: 16, gap: 16 }}>
      <Text style={{ fontWeight: '700' }}>@Input/@Output → props/callback</Text>
      <RatingStars value={rating} onChange={setRating} />
      <Text>Bạn chọn {rating} sao</Text>

      <Text style={{ fontWeight: '700' }}>Signals → useSignal</Text>
      <CartBadge />
      <Pressable accessibilityRole="button" onPress={() => cartCount.update((c) => c + 1)}>
        <Text>Thêm vào giỏ</Text>
      </Pressable>

      <Text style={{ fontWeight: '700' }}>DI → Context</Text>
      <Greeter name="Nobin" />
      <GreetingProvider service={formalGreeting}>
        <Greeter name="Nobin" />
      </GreetingProvider>

      <Text style={{ fontWeight: '700' }}>RxJS debounceTime → useDebouncedValue</Text>
      <TextInput accessibilityLabel="Tìm" value={query} onChangeText={setQuery} placeholder="Gõ để tìm" />
      <Text>Đang tìm: {debounced}</Text>
    </View>
  );
}
