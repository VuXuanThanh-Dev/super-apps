import { useRouter } from 'expo-router';
import { FlatList, StyleSheet, Text, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { PostCard } from '@/components/PostCard';
import { usePosts } from '@/features/posts/usePosts';
import { useFavorites } from '@/state/favorites';
import { colors, spacing } from '@/theme';

export default function FavoritesScreen() {
  const ids = useFavorites((s) => s.ids);
  const clear = useFavorites((s) => s.clear);
  const { data } = usePosts(); // dùng chung cache với tab Bài viết — không gọi mạng thêm
  const router = useRouter();
  const posts = (data?.posts ?? []).filter((p) => ids.includes(p.id));

  return (
    <View style={styles.screen}>
      <FlatList
        data={posts}
        keyExtractor={(p) => String(p.id)}
        renderItem={({ item, index }) => <PostCard post={item} index={index} onOpen={(id) => router.push(`/post/${id}`)} />}
        ListEmptyComponent={<Text style={styles.empty}>Chưa có bài yêu thích. Bấm 🤍 để thêm.</Text>}
      />
      {ids.length > 0 ? (
        <View style={{ padding: spacing.lg }}>
          <AppButton title={`Bỏ tất cả (${ids.length})`} variant="ghost" onPress={clear} />
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background },
  empty: { textAlign: 'center', color: colors.muted, marginTop: spacing.xl },
});
