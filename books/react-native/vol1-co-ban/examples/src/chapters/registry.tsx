import type { ComponentType } from 'react';
import { HelloExpo } from './ch01/HelloExpo';
import { AngularMappingDemo } from './ch02/AngularMappingDemo';
import { ComponentsDemo } from './ch03/ComponentsDemo';
import { FlexPlayground } from './ch04/FlexPlayground';
import { ContactList, ContactSections } from './ch05/ContactList';
import { SignUpForm } from './ch06/SignUpForm';
import { Alert } from 'react-native';

export interface LabEntry {
  id: string;
  title: string;
  Component: ComponentType;
}

// Danh sách ví dụ của từng chương, mở được từ tab "Lab" trong Expo Go.
export const LAB: LabEntry[] = [
  { id: 'ch01', title: 'Ch.1 — Hello Expo', Component: HelloExpo },
  { id: 'ch02', title: 'Ch.2 — Angular → React Native', Component: AngularMappingDemo },
  { id: 'ch03', title: 'Ch.3 — Component, props, state', Component: ComponentsDemo },
  { id: 'ch04', title: 'Ch.4 — Flexbox playground', Component: FlexPlayground },
  { id: 'ch05a', title: 'Ch.5 — FlatList + tìm kiếm', Component: () => <ContactList /> },
  { id: 'ch05b', title: 'Ch.5 — SectionList', Component: () => <ContactSections /> },
  {
    id: 'ch06',
    title: 'Ch.6 — Form đăng ký',
    Component: () => <SignUpForm onSubmit={(v) => Alert.alert('Đăng ký thành công', v.email)} />,
  },
];

export function findLab(id: string | undefined): LabEntry | undefined {
  return LAB.find((e) => e.id === id);
}
