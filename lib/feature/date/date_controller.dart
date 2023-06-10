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

  /// ListViewのindexに該当する日記を返す
//TODO check Providerに書くべきか、Controllerに書くべきかの判断がまだ腹落ちできていない
//TODO check ref.watch(diaryStreamProvider)を注入して使用する方法でも良いのか？
//TODO Providerで処理するもの＝値を監視したいもの、Controllerで処理するもの＝ユーザーの動作に起因するもの（自動処理も含む）
//TODO とした場合、以下の処理は、常に監視したいものではないので、Controllerの方が適切では？
//TODO （ただし、仮にControllerに書くとしてもDateControllerではなく、DiaryControllerで良さそう）
// Diary? getIndexDateDiary(List<Diary> diaryList, DateTime indexDate) {
//   final indexDateDiary = diaryList.firstWhereOrNull((diary) {
//     return diary.diaryDate == indexDate;
//   });
//   return indexDateDiary;
// }
}
