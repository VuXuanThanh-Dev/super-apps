import { useState } from 'react';
import { Pressable, Text } from 'react-native';

// Lời giải bài tập Chương 3: LikeButton có state "liked" và số lượt thích.
export function LikeButton({ initialLikes = 0 }: { initialLikes?: number }) {
  const [liked, setLiked] = useState(false);
  const likes = initialLikes + (liked ? 1 : 0); // "derived state": tính từ state, không lưu thêm
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: liked }}
      accessibilityLabel={liked ? 'Bỏ thích' : 'Thích'}
      onPress={() => setLiked((v) => !v)}
    >
      <Text>
        {liked ? '❤️' : '🤍'} {likes}
      </Text>
    </Pressable>
  );
}
