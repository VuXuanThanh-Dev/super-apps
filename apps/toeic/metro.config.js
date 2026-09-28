// Metro config: resolves the virtual module "@toeic/dataset".
// - If private-data/dataset.json exists (built by tools/build_dataset.py), the app uses it.
// - Otherwise it uses the small public sample in src/data/sample/dataset.json.
// This is how the app runs with private-data/ empty.
const fs = require('fs');
const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);
const privateDataset = path.join(__dirname, 'private-data', 'dataset.json');
const sampleDataset = path.join(__dirname, 'src', 'data', 'sample', 'dataset.json');

const upstream = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (moduleName === '@toeic/dataset') {
    const filePath = fs.existsSync(privateDataset) ? privateDataset : sampleDataset;
    return { type: 'sourceFile', filePath };
  }
  return upstream ? upstream(context, moduleName, platform) : context.resolveRequest(context, moduleName, platform);
};

module.exports = config;
