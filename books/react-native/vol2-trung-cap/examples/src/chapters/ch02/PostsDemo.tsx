import { useQuery } from '@tanstack/react-query';
import { ActivityIndicator, Pressable, Text, View } from 'react-native';
import { fetchPosts, postKeys } from '@/api/posts';

// Chương 2: useQuery cơ bản — 3 trạng thái: đang tải / lỗi / có dữ liệu.
export function PostsDemo({ limit = 5 }: { limit?: number }) {
  const query = useQuery({ queryKey: postKeys.list(limit), queryFn: () => fetchPosts(limit) });

  if (query.isPending) return <ActivityIndicator accessibilityLabel="Đang tải" />;
  if (query.isError)
    return (
      <View style={{ padding: 16, gap: 8 }}>
        <Text>Lỗi: {query.error.message}</Text>
        <Pressable accessibilityRole="button" onPress={() => query.refetch()}>
          <Text>Thử lại</Text>
        </Pressable>
      </View>
    );
  return (
    <View style={{ padding: 16, gap: 8 }}>
      {query.data.map((p) => (
        <Text key={p.id}>• {p.title}</Text>
      ))}
    </View>
  );
}
