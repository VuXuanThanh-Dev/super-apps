import React, { useEffect, useState } from 'react';
import { ScrollView, Text, View } from 'react-native';

type Contact = { id: string; name: string; phone: string };

export default function ContactList({ load }: { load: () => Promise<Contact[]> }) {
  const [contacts, setContacts] = useState<Contact[]>([]);
  useEffect(() => {
    load().then(setContacts);
  });
  return (
    <ScrollView>
      {contacts.map((c) => (
        <View>
          <Text>{c.name}</Text>
          <Text>{c.phone}</Text>
        </View>
      ))}
    </ScrollView>
  );
}
