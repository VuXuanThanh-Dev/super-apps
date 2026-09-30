# private-data/ — dữ liệu lấy từ sách (KHÔNG commit)

Mọi thứ trong thư mục này lấy từ hai cuốn sách ở gốc repo
(`TOEIC-900-Word-Families-Collocations-Tap1.pdf`, `...-Tap2.pdf`), chỉ để Nobin học riêng.

- Thư mục bị **git-ignore** (chỉ commit file README này) vì repo GitHub là **public**.
- App vẫn chạy khi thư mục rỗng: khi đó app dùng bộ mẫu nhỏ `assets/data/sample.db`.

## Tạo lại (khoảng 20 giây)

```bash
cd apps/toeic-flutter
pip install -r ../toeic/tools/requirements.txt
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh
```

| File | Nội dung |
|---|---|
| `toeic.db` | Dữ liệu đầy đủ dạng SQLite. **Được đóng gói vào app** (asset) nếu tồn tại |
| `source/dataset.json` | Bản sao `apps/toeic/private-data/dataset.json` (Task 5) |
| `source/dataset-merged.json` | `dataset.json` + từ của bạn (`my-words/`) — đầu vào của `toeic.db` |
| `my-words/*.txt` | Từ bạn tự thêm (`python3 tools/import_words.py <file>`) |

Chỉ file nằm **trực tiếp** trong thư mục này (README.md, toeic.db) được đóng gói vào app;
thư mục con (`source/`, `my-words/`) thì không.

## Xoá trước khi public

Xem README chính, mục "Xoá dữ liệu riêng".
