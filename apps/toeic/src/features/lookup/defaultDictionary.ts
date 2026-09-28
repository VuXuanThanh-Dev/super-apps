import { dataIndex, functionWords, genericGlosses } from '@/data';
import { Dictionary } from './dictionary';
import irregular from './irregular.json';

/** The app's offline dictionary (bundled data only, no network). */
export const defaultDictionary = new Dictionary({
  index: dataIndex,
  functionWords,
  genericGlosses,
  irregular: irregular as Record<string, string>,
});
