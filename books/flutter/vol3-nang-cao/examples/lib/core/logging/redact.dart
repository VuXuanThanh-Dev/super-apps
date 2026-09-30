/// Che dữ liệu nhạy cảm trước khi ghi log: email và dãy từ 4 chữ số trở lên (PIN, số thẻ…).
String redact(String message) =>
    message.replaceAll(RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+'), '<email>').replaceAll(RegExp(r'\d{4,}'), '<số>');
