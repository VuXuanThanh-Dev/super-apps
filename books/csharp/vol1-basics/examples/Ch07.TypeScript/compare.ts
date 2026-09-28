// Same problem in TypeScript.
type User = { readonly id: number; readonly name: string; readonly age: number; readonly email: string | null };

const users: User[] = [
  { id: 1, name: "An", age: 28, email: "an@example.com" },
  { id: 2, name: "Bình", age: 17, email: null },
  { id: 3, name: "Chi", age: 35, email: "chi@example.com" },
];

// 1. filter + map
const adults = users.filter(u => u.age >= 18).map(u => u.name.toUpperCase());
console.log(`Người lớn: ${adults.join(", ")}`);

// 2. ?. and ??
for (const u of users) console.log(`${u.name}: ${u.email?.length.toString() ?? "không có email"}`);

// 3. spread copy (no built-in value equality)
const older = { ...users[0], age: 29 };
const same: User = { id: 1, name: "An", age: 28, email: "an@example.com" };
console.log(JSON.stringify(older));
console.log(`users[0] === bản sao cùng dữ liệu? ${users[0] === same}`);

async function findNameAsync(id: number): Promise<string> {
  await new Promise(r => setTimeout(r, 10));
  const user = users.find(u => u.id === id);
  if (!user) throw new Error(`User ${id} không tồn tại`);
  return user.name;
}

async function main() {
  // 4. async/await
  console.log(`Tìm thấy: ${await findNameAsync(3)}`);
  // 5. exceptions
  try {
    await findNameAsync(99);
  } catch (e) {
    console.log(`Lỗi: ${(e as Error).message}`);
  }
}
main();
