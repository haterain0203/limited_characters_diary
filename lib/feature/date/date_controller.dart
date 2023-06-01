import 'package:hooks_riverpod/hooks_riverpod.dart';

class DateController {
  DateController({
    required this.today,
    required this.selectedDate,
    required this.selectedMonth,
    required this.todayNotifier,
    required this.selectedMonthNotifier,
    required this.isJumpedToAroundToday,
  });

  final DateTime today;
  final DateTime selectedDate;
  final DateTime selectedMonth;
  final StateController<DateTime> todayNotifier;
  final StateController<DateTime> selectedMonthNotifier;
  final bool isJumpedToAroundToday;

  void showNextMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
      );
    });
  }

  void showPreviousMonth() {
    selectedMonthNotifier.update((state) {
      return DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
    });
  }

  //TODO check 選択された月の状態が必要なため、extensionではなくcontrollerとしたがどうか？
  int daysInMonth() {
    //https://note.com/hatchoutschool/n/ne95862d50623
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
    ).add(const Duration(days: -1)).day;
    return daysInMonth;
  }

  bool isToday(DateTime indexDate) {
    return indexDate.isAtSameMomentAs(today);
  }

  /// バックグラウンドから復帰時した点の日付とバックグラウンド移行時の日付が異なる場合、値を更新する
  ///
  /// 本日の日付をハイライトさせているが、
  /// アプリをバックグラウンド→翌日にフォアグラウンドに復帰（resume）→アプリは再起動しない場合がある（端末依存）→日付が更新されずにハイライト箇所が正しくならない
  /// 上記の事象へ対応するもの
  void updateToCurrentDate() {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    // バックグラウンド移行時の日と復帰時の日が一緒の場合は処理終了
    if (isToday(nowDate)) {
      return;
    }
    todayNotifier.update(
      (_) {
        return DateTime(now.year, now.month, now.day);
      },
    );
  }

  /// 今日-5日に自動で画面スクロールするかどうか
  bool shouldJumpToAroundToday() {
    // 既にスクロール済みならfalseを返す（スクロールさせない）
    if (isJumpedToAroundToday) {
      return false;
    }
    if (selectedMonth.month != today.month) {
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
      selectedMonth.year,
      selectedMonth.month,
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
