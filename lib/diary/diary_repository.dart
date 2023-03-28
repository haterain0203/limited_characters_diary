import 'package:isar/isar.dart';

import 'collection/diary.dart';

// 参考URL
// https://zenn.dev/flutteruniv_dev/articles/20220607-061331-flutter-isar?redirected=1#%E3%83%A1%E3%83%A2%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%82%AF%E3%83%A9%E3%82%B9%E3%82%92%E4%BD%9C%E6%88%90%E3%81%99%E3%82%8B
class DiaryRepository {
  DiaryRepository(this.isar);

  /// Isarインスタンス
  final Isar isar;

  /// 日記を取得する
  Future<List<Diary>> findDiaryList(DateTime selectedMonth) async {
    if (!isar.isOpen) {
      return [];
    }

    // 更新日時の降順で全件返す
    final diaryList = await isar.diarys
        .where()
        .diaryDateBetween(
          selectedMonth,
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0),
        )
        .sortByDiaryDate()
        .findAll();

    return diaryList;
  }

  /// 日記を追加する
  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) {
    if (!isar.isOpen) {
      return Future<void>(() {});
    }

    final now = DateTime.now();
    final diary = Diary()
      ..content = content
      ..diaryDate = selectedDate
      ..createdAt = now
      ..updatedAt = now;
    return isar.writeTxn(() async {
      await isar.diarys.put(diary);
    });
  }

  /// 日記を更新する
  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) {
    if (!isar.isOpen) {
      return Future<void>(() {});
    }

    final now = DateTime.now();
    diary
      ..content = content
      ..updatedAt = now;
    return isar.writeTxn(() async {
      await isar.diarys.put(diary);
    });
  }

  /// 日記を削除する
  Future<bool> deleteDiary(Diary diary) async {
    if (!isar.isOpen) {
      return false;
    }

    return isar.writeTxn(() async {
      return isar.diarys.delete(diary.id);
    });
  }
}
