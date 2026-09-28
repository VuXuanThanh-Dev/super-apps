import { Image, Pressable, StyleSheet, Text, View, type ImageSourcePropType } from 'react-native';

export interface Profile {
  name: string;
  role: string;
  avatar: ImageSourcePropType; // ảnh local: require('...png'); ảnh mạng: { uri: 'https://...' }
}

// Component = một hàm nhận props và trả về JSX.
// Chú ý: mọi chữ phải nằm trong <Text>; <View> giống <div>.
export function ProfileCard({ profile, onFollow, following }: {
  profile: Profile;
  following: boolean;
  onFollow: () => void;
}) {
  return (
    <View style={styles.card}>
      <Image source={profile.avatar} style={styles.avatar} accessibilityLabel={`Ảnh của ${profile.name}`} />
      <View style={styles.info}>
        <Text style={styles.name}>{profile.name}</Text>
        <Text style={styles.role}>{profile.role}</Text>
      </View>
      <Pressable accessibilityRole="button" onPress={onFollow} style={styles.button}>
        <Text style={styles.buttonText}>{following ? 'Đang theo dõi' : 'Theo dõi'}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 16, backgroundColor: '#fff', borderRadius: 12 },
  avatar: { width: 56, height: 56, borderRadius: 28, backgroundColor: '#e5e7eb' },
  info: { flex: 1 },
  name: { fontSize: 17, fontWeight: '700' },
  role: { color: '#6b7280' },
  button: { backgroundColor: '#2563eb', paddingVertical: 8, paddingHorizontal: 12, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '600' },
});
