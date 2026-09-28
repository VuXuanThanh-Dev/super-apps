import type { ComponentType } from 'react';
import { RuntimeInfoCard } from './ch01/RuntimeInfoCard';
import { TextStatsDemo } from './ch02/TextStatsDemo';
import { RenderCountDemo } from './ch03/RenderCountDemo';

export interface LabEntry {
  id: string;
  title: string;
  Component: ComponentType;
}

export const LAB: LabEntry[] = [
  { id: 'ch01', title: 'Ch.1 — Runtime: Hermes, TurboModule', Component: RuntimeInfoCard },
  { id: 'ch02', title: 'Ch.2 — Native module text-stats', Component: TextStatsDemo },
  { id: 'ch03', title: 'Ch.3 — Đếm số lần render', Component: () => <RenderCountDemo /> },
];

export const findLab = (id: string | undefined) => LAB.find((e) => e.id === id);
