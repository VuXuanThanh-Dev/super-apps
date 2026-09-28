// Returns emails that appear more than once (case-insensitive).
function findDuplicates(emails) {
  const result = [];
  for (let i = 0; i < emails.length; i++) {
    for (let j = i + 1; j < emails.length; j++) {
      const a = emails[i].toLowerCase();
      const b = emails[j].toLowerCase();
      if (a === b && !result.includes(a)) result.push(a);
    }
  }
  return result;
}
module.exports = { findDuplicates };
