import type { ComponentType } from 'react';
import { CartDemo } from './ch01/CartDemo';
import { PostsDemo } from './ch02/PostsDemo';
import { SqliteDemo } from './ch03/SqliteDemo';
import { AnimationDemo } from './ch04/AnimationDemo';
import { DeviceDemo } from './ch05/DeviceDemo';
import { ConfirmDeleteButton } from './ch06/ConfirmDeleteButton';

export interface LabEntry {
  id: string;
  title: string;
  Component: ComponentType;
}

function ConfirmDemo() {
  return <ConfirmDeleteButton itemName="bài mẫu" onConfirm={() => {}} />;
}

export const LAB: LabEntry[] = [
  { id: 'ch01', title: 'Ch.1 — Zustand vs useReducer', Component: CartDemo },
  { id: 'ch02', title: 'Ch.2 — useQuery cơ bản', Component: () => <PostsDemo /> },
  { id: 'ch03', title: 'Ch.3 — SQLite trên máy', Component: SqliteDemo },
  { id: 'ch04', title: 'Ch.4 — Animation', Component: AnimationDemo },
  { id: 'ch05', title: 'Ch.5 — Device APIs', Component: DeviceDemo },
  { id: 'ch06', title: 'Ch.6 — Alert xác nhận (để test)', Component: ConfirmDemo },
];

export const findLab = (id: string | undefined) => LAB.find((e) => e.id === id);
