// Cấu hình Metro — chỉ cần cho bản web của expo-sqlite (theo tài liệu expo-sqlite SDK 57).
// Trên iPhone/Expo Go không cần phần này.
const { getDefaultConfig } = require('expo/metro-config');

/** @type {import('expo/metro-config').MetroConfig} */
const config = getDefaultConfig(__dirname);

// Cho phép đóng gói file .wasm (SQLite trên web chạy bằng WebAssembly)
config.resolver.assetExts.push('wasm');

// Header COEP/COOP để trình duyệt cho dùng SharedArrayBuffer
config.server.enhanceMiddleware = (middleware) => {
  return (req, res, next) => {
    res.setHeader('Cross-Origin-Embedder-Policy', 'credentialless');
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    middleware(req, res, next);
  };
};

module.exports = config;
