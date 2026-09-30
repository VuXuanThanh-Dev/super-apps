import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web: sqflite không có bản web → dùng SQLite biên dịch sang WebAssembly
/// (cần web/sqlite3.wasm và web/sqflite_sw.js, tạo bằng `dart run sqflite_common_ffi_web:setup`).
void configureDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
