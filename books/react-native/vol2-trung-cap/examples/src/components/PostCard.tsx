import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import type { Post } from '@/api/types';
import { colors, spacing } from '@/theme';
import { FavoriteButton } from './FavoriteButton';

function PostCardBase({ post, index, onOpen }: { post: Post; index: number; onOpen: (id: number) => void }) {
  return (
    // Layout animation: thẻ trượt lên khi xuất hiện, trễ dần theo vị trí.
    <Animated.View entering={FadeInDown.delay(Math.min(index, 10) * 40)} style={styles.card}>
      <Pressable accessibilityRole="button" accessibilityLabel={`Mở ${post.title}`} style={styles.body} onPress={() => onOpen(post.id)}>
        <Text style={styles.title} numberOfLines={2}>
          {post.title}
        </Text>
        <Text style={styles.excerpt} numberOfLines={2}>
          {post.body}
        </Text>
      </Pressable>
      <View style={styles.actions}>
        <FavoriteButton postId={post.id} />
      </View>
    </Animated.View>
  );
}

export const PostCard = memo(PostCardBase);

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    backgroundColor: colors.card,
    marginHorizontal: spacing.lg,
    marginVertical: spacing.xs,
    borderRadius: 12,
    padding: spacing.md,
    gap: spacing.md,
  },
  body: { flex: 1, gap: 4 },
  title: { fontWeight: '700', fontSize: 16, color: colors.text, textTransform: 'capitalize' },
  excerpt: { color: colors.muted },
  actions: { justifyContent: 'center' },
});
