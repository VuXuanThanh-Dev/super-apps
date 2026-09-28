import { Alert, Pressable, Text } from 'react-native';

// Nút xóa có hộp thoại xác nhận — Alert.alert là API native, cần mock khi test.
export function ConfirmDeleteButton({ itemName, onConfirm }: { itemName: string; onConfirm: () => void }) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={() =>
        Alert.alert('Xóa?', itemName, [
          { text: 'Hủy', style: 'cancel' },
          { text: 'Xóa', style: 'destructive', onPress: onConfirm },
        ])
      }
    >
      <Text>Xóa {itemName}</Text>
    </Pressable>
  );
}
