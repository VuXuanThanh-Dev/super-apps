// The dataset is a virtual module: Metro maps it to private-data/dataset.json
// when that file exists, otherwise to src/data/sample/dataset.json
// (see metro.config.js and jest.config.js). tsc does not depend on either file.
declare module '@toeic/dataset' {
  import type { Dataset } from '@/data/types';
  const dataset: Dataset;
  export default dataset;
}
