// Bộ sinh số ngẫu nhiên có seed (mulberry32) để quiz test được — port từ Task 5 (quiz/random.ts).
typedef Rng = double Function();

/// Nhân 32 bit như Math.imul của JavaScript. Tách 16 bit để không tràn số trên web
/// (int trên web là số thực 53 bit).
int imul32(int x, int y) {
  final xh = (x >> 16) & 0xFFFF, xl = x & 0xFFFF, yh = (y >> 16) & 0xFFFF, yl = y & 0xFFFF;
  return (xl * yl + (((xh * yl + xl * yh) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

Rng mulberry32(int seed) {
  var a = seed & 0xFFFFFFFF;
  return () {
    a = (a + 0x6d2b79f5) & 0xFFFFFFFF;
    var t = a;
    t = imul32(t ^ (t >> 15), t | 1);
    t ^= (t + imul32(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296;
  };
}

List<T> shuffle<T>(Iterable<T> items, Rng rng) {
  final a = [...items];
  for (var i = a.length - 1; i > 0; i--) {
    final j = (rng() * (i + 1)).floor();
    final tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

List<T> pick<T>(Iterable<T> items, int n, Rng rng) => shuffle(items, rng).take(n).toList();
