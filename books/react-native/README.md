# Bộ sách React Native — từ cơ bản đến nâng cao (tiếng Việt)

Dành cho **Angular developer** muốn làm app mobile, test trên **iPhone bằng Expo Go**.
Markdown là nguồn chính; PDF được build bằng script.

| Tập | Nội dung | Markdown | PDF | App mẫu |
|---|---|---|---|---|
| 1 — Cơ bản | Cài đặt, **React Native cho Angular developer**, component, styling/Flexbox, danh sách, form, Expo Router | [vol1-co-ban/](vol1-co-ban/README.md) | [dist/React-Native-Tap1-Co-Ban.pdf](dist/React-Native-Tap1-Co-Ban.pdf) | "Việc Cần Làm" |
| 2 — Trung cấp | Zustand, TanStack Query, AsyncStorage/SQLite, Reanimated, device APIs, testing | [vol2-trung-cap/](vol2-trung-cap/README.md) | [dist/React-Native-Tap2-Trung-Cap.pdf](dist/React-Native-Tap2-Trung-Cap.pdf) | "Tin Đọc Sau" |
| 3 — Nâng cao | New Architecture, native module, performance, security, CI/CD, phát hành, monitoring | [vol3-nang-cao/](vol3-nang-cao/README.md) | [dist/React-Native-Tap3-Nang-Cao.pdf](dist/React-Native-Tap3-Nang-Cao.pdf) | "Sổ Ghi Chú Bảo Mật" |

- Phiên bản và lý do chọn: [STACK.md](STACK.md) (Expo SDK 57, React Native 0.86.3, React 19.2.3, TypeScript 6.0.3, Node 22).
- Thuật ngữ: [GLOSSARY.md](GLOSSARY.md). Kế hoạch: [PLAN.md](PLAN.md). Tiến độ: [PROGRESS.md](PROGRESS.md).
- Bắt đầu nhanh cho Angular dev: [Tập 1, Chương 2](vol1-co-ban/02-react-native-cho-angular-developer.md).

## Phiên bản công cụ (ghim chính xác)

| Công cụ | Phiên bản |
|---|---|
| Node.js | 22.22.2 (tối thiểu 20.19.4) |
| npm | 10.9.7 |
| Expo SDK | 57 (`expo@57.0.25`) |
| React Native / React | 0.86.3 / 19.2.3 |
| TypeScript | 6.0.3 |
| Jest / jest-expo / RNTL | 29.7.0 / 57.0.5 / 14.0.1 |
| ESLint / eslint-config-expo | 9.39.5 / 57.0.2 |
| pandoc (build PDF) | 3.1.3 |
| playwright-core / mermaid (build PDF) | 1.56.1 / 12.0.0 |

Phiên bản thư viện từng app nằm trong `vol*/examples/package.json` + `package-lock.json`.

## Chạy một app trên iPhone

```bash
cd books/react-native/vol1-co-ban/examples   # hoặc vol2-trung-cap / vol3-nang-cao
npm ci
npx expo login     # cùng tài khoản Expo với app Expo Go (bắt buộc từ SDK 57 trên iPhone thật)
npx expo start     # quét mã QR bằng Camera
```

**Chạy trên Expo Go: NOT RUN (không có iPhone trong sandbox).** Expo Go trên App Store chỉ hỗ trợ SDK
mới nhất; khi SDK 58 ra mắt, nâng cấp bằng `npx expo install expo@^58.0.0 --fix` (xem STACK.md).

## Kiểm tra toàn bộ (type-check, lint, test, bundle)

```bash
bash books/react-native/scripts/check-all.sh          # cả 3 tập
bash books/react-native/scripts/check-all.sh vol2-trung-cap
```

Kết quả ngày 2026-09-28 (log: [logs/check-all.txt](logs/check-all.txt)):

| Tập | tsc | eslint (0 warning) | Jest | expo export web / ios |
|---|---|---|---|---|
| 1 | OK | OK | 16 suites, 57 tests | OK / OK |
| 2 | OK | OK | 11 suites, 43 tests | OK / OK |
| 3 | OK | OK | 10 suites, 45 tests (+ YAML CI OK) | OK / OK |

## Build PDF

```bash
cd books/react-native/scripts
npm ci
node build-pdf.mjs            # → ../dist/*.pdf (pandoc → HTML → Chromium; Mermaid vẽ trong trang)
bash check-pdf-accents.sh     # pdftotext: kiểm tra ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ
python3 check-links.py        # kiểm tra link (host bị chặn được báo riêng)
```

Font: Noto Serif (chữ), Noto Sans (tiêu đề), Noto Sans Mono (code), Noto Color Emoji.

## Cấu trúc

```text
books/react-native/
  README.md PLAN.md PROGRESS.md STACK.md GLOSSARY.md
  vol1-co-ban/     01..08-*.md  examples/ (Expo app + code từng chương + test)
  vol2-trung-cap/  01..07-*.md  examples/
  vol3-nang-cao/   01..08-*.md  examples/ (+ modules/text-stats)  ci/ (workflow mẫu)
  scripts/         check-all.sh  build-pdf.mjs  check-pdf-accents.sh  check-links.py
  dist/            3 PDF
  logs/            output thật của các lần kiểm tra
```
