import { useRouter } from 'expo-router';
import { useCallback } from 'react';
import { ActivityIndicator, FlatList, StyleSheet, Text, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { OfflineBanner } from '@/components/OfflineBanner';
import { PostCard } from '@/components/PostCard';
import { formatSavedAt } from '@/features/posts/format';
import { usePosts } from '@/features/posts/usePosts';
import { colors, spacing } from '@/theme';

export default function PostsScreen() {
  const { data, isPending, isError, error, refetch, isRefetching } = usePosts();
  const router = useRouter();
  const open = useCallback((id: number) => router.push(`/post/${id}`), [router]);

  if (isPending) {
    return (
      <View style={styles.center}>
        <ActivityIndicator accessibilityLabel="Đang tải" />
      </View>
    );
  }

  if (isError) {
    return (
      <View style={styles.center}>
        <Text style={styles.error}>Không tải được bài viết: {error.message}</Text>
        <AppButton title="Thử lại" onPress={() => refetch()} />
      </View>
    );
  }

  return (
    <View style={styles.screen}>
      <OfflineBanner />
      {data.source === 'cache' ? (
        <Text style={styles.note}>Dữ liệu offline, lưu lúc {formatSavedAt(data.savedAt)}</Text>
      ) : null}
      <FlatList
        data={data.posts}
        keyExtractor={(p) => String(p.id)}
        renderItem={({ item, index }) => <PostCard post={item} index={index} onOpen={open} />}
        refreshing={isRefetching}
        onRefresh={() => refetch()}
        contentContainerStyle={{ paddingVertical: spacing.sm }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing.md, padding: spacing.xl },
  error: { color: colors.danger, textAlign: 'center' },
  note: { textAlign: 'center', color: colors.muted, paddingTop: spacing.sm },
});
