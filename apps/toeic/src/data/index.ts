import dataset from '@toeic/dataset';
import dialogsJson from '@/content/dialogs.json';
import functionWordsJson from '@/content/function-words.json';
import genericGlossesJson from './generic-glosses.json';
import { DataIndex } from './DataIndex';
import type { Dialog, FunctionWord, Gloss } from './types';

/** The dataset chosen at build time: private-data/dataset.json or the sample. */
export const dataIndex = new DataIndex(dataset);
export const dialogs: Dialog[] = dialogsJson as Dialog[];
export const functionWords: Record<string, FunctionWord> = functionWordsJson as Record<string, FunctionWord>;
export const genericGlosses: Record<string, Gloss> = genericGlossesJson as Record<string, Gloss>;
export const isSampleData = dataset.source === 'sample';
