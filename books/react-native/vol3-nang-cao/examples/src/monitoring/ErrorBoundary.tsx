import { Component, type ErrorInfo, type ReactNode } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { logger } from './logger';

interface Props {
  children: ReactNode;
  onError?: (error: Error) => void;
}
interface State {
  error: Error | null;
}

// Error Boundary phải là class component (React chưa có hook tương đương).
// Nó bắt lỗi khi RENDER của các component con — không bắt lỗi trong event handler hay Promise.
export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.reportError(error, { componentStack: (info.componentStack ?? '').slice(0, 500) });
    this.props.onError?.(error);
  }

  reset = () => this.setState({ error: null });

  render() {
    if (!this.state.error) return this.props.children;
    return (
      <View style={styles.box}>
        {/* role="alert" đặt trên Text: View chỉ được coi là phần tử accessibility khi có accessible={true} */}
        <Text accessibilityRole="alert" style={styles.title}>
          Đã có lỗi xảy ra 😢
        </Text>
        <Text style={styles.msg}>{this.state.error.message}</Text>
        <Pressable accessibilityRole="button" onPress={this.reset} style={styles.btn}>
          <Text style={styles.btnText}>Thử lại</Text>
        </Pressable>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  box: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  title: { fontSize: 20, fontWeight: '700' },
  msg: { color: '#6b7280', textAlign: 'center' },
  btn: { backgroundColor: '#2563eb', paddingVertical: 10, paddingHorizontal: 18, borderRadius: 8 },
  btnText: { color: '#fff', fontWeight: '600' },
});
