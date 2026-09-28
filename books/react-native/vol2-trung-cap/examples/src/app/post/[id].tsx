import { useQuery } from '@tanstack/react-query';
import { Stack, useLocalSearchParams } from 'expo-router';
import { ActivityIndicator, ScrollView, StyleSheet, Text, View } from 'react-native';
import { fetchPost, postKeys } from '@/api/posts';
import { FavoriteButton } from '@/components/FavoriteButton';
import { usePosts } from '@/features/posts/usePosts';
import { colors, spacing } from '@/theme';

export default function PostDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const postId = Number(id); // tham số URL luôn là chuỗi → đổi sang số
  const list = usePosts();
  const fromList = list.data?.posts.find((p) => p.id === postId);

  // Nếu bài đã có trong danh sách (kể cả cache offline) thì dùng luôn, khỏi gọi mạng.
  const { data: post, isPending, isError } = useQuery({
    queryKey: postKeys.detail(postId),
    queryFn: () => fetchPost(postId),
    initialData: fromList,
    enabled: Number.isFinite(postId),
  });

  if (isPending) return <ActivityIndicator style={{ marginTop: spacing.xl }} accessibilityLabel="Đang tải" />;
  if (isError || !post) return <Text style={styles.body}>Không tìm thấy bài viết.</Text>;

  return (
    <ScrollView contentContainerStyle={styles.screen}>
      <Stack.Screen options={{ title: `Bài #${post.id}` }} />
      <View style={styles.header}>
        <Text style={styles.title}>{post.title}</Text>
        <FavoriteButton postId={post.id} />
      </View>
      <Text style={styles.body}>{post.body}</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  screen: { padding: spacing.lg, gap: spacing.lg },
  header: { flexDirection: 'row', gap: spacing.md, alignItems: 'flex-start' },
  title: { flex: 1, fontSize: 22, fontWeight: '800', color: colors.text, textTransform: 'capitalize' },
  body: { fontSize: 16, lineHeight: 24, color: colors.text, padding: spacing.lg },
});
