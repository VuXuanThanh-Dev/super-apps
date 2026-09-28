import * as SQLite from 'expo-sqlite';
import { useEffect, useState } from 'react';
import { Text, TextInput, View } from 'react-native';
import { createSqlitePostsCache, migrate, searchCachedPosts } from '@/storage/sqlitePostsCache';
import { POSTS } from '@/test/fixtures';

// Chương 3: mở SQLite thật trên điện thoại (expo-sqlite), lưu 3 bài mẫu, tìm theo tiêu đề.
export function SqliteDemo() {
  const [db, setDb] = useState<SQLite.SQLiteDatabase | null>(null);
  const [keyword, setKeyword] = useState('');
  const [titles, setTitles] = useState<string[]>([]);

  useEffect(() => {
    let alive = true;
    (async () => {
      const opened = await SQLite.openDatabaseAsync('book-demo.db');
      await migrate(opened);
      await createSqlitePostsCache(opened).save(POSTS);
      if (alive) setDb(opened);
    })();
    return () => {
      alive = false; // tránh setState sau khi màn hình đã đóng
    };
  }, []);

  useEffect(() => {
    if (!db) return;
    searchCachedPosts(db, keyword).then((rows) => setTitles(rows.map((r) => r.title)));
  }, [db, keyword]);

  return (
    <View style={{ padding: 16, gap: 8 }}>
      <Text>{db ? 'SQLite sẵn sàng' : 'Đang mở database...'}</Text>
      <TextInput accessibilityLabel="Tìm trong SQLite" value={keyword} onChangeText={setKeyword} placeholder="Gõ từ khóa" />
      {titles.map((t) => (
        <Text key={t}>• {t}</Text>
      ))}
    </View>
  );
}
