import { Link } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { LAB } from '@/chapters/registry';
import { AppButton } from '@/components/AppButton';
import { logger } from '@/monitoring/logger';
import { useAuth } from '@/state/auth';
import { colors, spacing } from '@/theme';

function CrashOnRender(): never {
  throw new Error('Lỗi thử nghiệm từ màn hình Cài đặt');
}

export default function SettingsScreen() {
  const lockNow = useAuth((s) => s.lockNow);
  const [crash, setCrash] = useState(false);
  const crumbs = logger.breadcrumbs().slice(-5).reverse();

  return (
    <ScrollView contentContainerStyle={styles.screen}>
      <AppButton title="🔒 Khóa ngay" onPress={lockNow} />
      <AppButton
        title="💥 Thử lỗi (Error Boundary)"
        variant="ghost"
        onPress={() => {
          logger.addBreadcrumb('warn', 'settings.crash_test');
          setCrash(true);
        }}
      />
      {crash ? <CrashOnRender /> : null}

      <Text style={styles.heading}>5 breadcrumb gần nhất</Text>
      {crumbs.length === 0 ? <Text style={styles.muted}>(chưa có)</Text> : null}
      {crumbs.map((c) => (
        <Text key={`${c.at}-${c.message}`} style={styles.muted}>
          [{c.level}] {c.message}
        </Text>
      ))}

      <Text style={styles.heading}>Lab</Text>
      <View style={{ gap: spacing.sm }}>
        {LAB.map((e) => (
          <Link key={e.id} href={{ pathname: '/lab/[id]', params: { id: e.id } }} style={styles.link}>
            {e.title}
          </Link>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  screen: { padding: spacing.lg, gap: spacing.md },
  heading: { fontWeight: '700', marginTop: spacing.lg },
  muted: { color: colors.muted },
  link: { color: colors.primary, paddingVertical: spacing.sm },
});
