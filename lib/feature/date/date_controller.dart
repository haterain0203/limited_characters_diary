class DateController {
  DateController({
    required this.selectedDateTime,
    required this.isJumpedToAroundToday,
  });

  final DateTime selectedDateTime;
  final bool isJumpedToAroundToday;

  /// 今日-5日に自動で画面スクロールするかどうか
  bool shouldJumpToAroundToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 既にスクロール済みならfalseを返す（スクロールさせない）
    if (isJumpedToAroundToday) {
      return false;
    }
    if (selectedDateTime.month != today.month) {
      return false;
    }
    if (today.day <= 10) {
      return false;
    }
    return true;
  }

  /// ListViewのindexに該当する日付を返す
  //TODO check これはユーザー操作ではないため、View側に移動したいが、移動方法について確認
  DateTime indexToDateTime(int index) {
    return DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      index + 1,
    );
  }
}
