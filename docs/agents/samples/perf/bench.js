const { findDuplicates } = require('./find-duplicates');
const N = 20000;
const emails = Array.from({ length: N }, (_, i) => `user${i % (N - 500)}@Example.com`);
const t0 = process.hrtime.bigint();
const dups = findDuplicates(emails);
const ms = Number(process.hrtime.bigint() - t0) / 1e6;
console.log(`N=${N} duplicates=${dups.length} time=${ms.toFixed(1)}ms`);
