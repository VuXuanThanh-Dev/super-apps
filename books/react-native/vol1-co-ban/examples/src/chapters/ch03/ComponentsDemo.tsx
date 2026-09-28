import { useState } from 'react';
import { ScrollView } from 'react-native';
import { Clock } from './Clock';
import { Counter } from './Counter';
import { ProfileCard } from './ProfileCard';

export function ComponentsDemo() {
  const [following, setFollowing] = useState(false);
  return (
    <ScrollView contentContainerStyle={{ padding: 16, gap: 24 }}>
      <ProfileCard
        profile={{ name: 'Nobin', role: 'Frontend lead', avatar: require('../../../assets/icon.png') }}
        following={following}
        onFollow={() => setFollowing((f) => !f)}
      />
      <Counter step={2} />
      <Clock />
    </ScrollView>
  );
}
