// Port từ Task 5 (saved/reminders.ts): nội dung thông báo nhắc ôn hằng ngày.
String reminderBody({required int savedCount, required int dueCount}) {
  if (dueCount > 0) return 'You have $dueCount cards to review. Ôn $dueCount thẻ hôm nay nhé!';
  if (savedCount > 0) return 'Review your $savedCount saved words. Ôn lại từ đã lưu nhé!';
  return 'Time for 10 minutes of TOEIC words. Học 10 phút nhé!';
}
