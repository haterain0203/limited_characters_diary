import 'package:cloud_firestore/cloud_firestore.dart';

import 'diary.dart';

class DiaryRepository {
  DiaryRepository({required this.fireStore, this.uid, required this.diaryRef});
  final FirebaseFirestore fireStore;
  final String? uid;
  final CollectionReference<Diary> diaryRef;

  Stream<List<Diary>> subscribedDiaryList() {
    final snapshots = diaryRef.snapshots();
    final diaryList = snapshots.map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
    return diaryList;
  }

  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    //TODO
    // final id = ;
    final now = DateTime.now();
    final diary = Diary(
      id: id,
      content: content,
      diaryDate: selectedDate,
      createdAt: now,
      updatedAt: now,
    );
    await diaryRef.add(diary);
  }

  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {}

  // DiaryRepository(this.isar);
  //
  // /// Isarインスタンス
  // final Isar isar;
  //
  // /// 日記を取得する
  // Future<List<Diary>> findDiaryList(DateTime selectedMonth) async {
  //   if (!isar.isOpen) {
  //     return [];
  //   }
  //
  //   // 更新日時の降順で全件返す
  //   final diaryList = await isar.diarys
  //       .where()
  //       .diaryDateBetween(
  //         selectedMonth,
  //         DateTime(selectedMonth.year, selectedMonth.month + 1, 0),
  //       )
  //       .sortByDiaryDate()
  //       .findAll();
  //
  //   return diaryList;
  // }
  //
  // /// 日記を追加する
  // Future<void> addDiary({
  //   required String content,
  //   required DateTime selectedDate,
  // }) {
  //   if (!isar.isOpen) {
  //     return Future<void>(() {});
  //   }
  //
  //   final now = DateTime.now();
  //   final diary = Diary()
  //     ..content = content
  //     ..diaryDate = selectedDate
  //     ..createdAt = now
  //     ..updatedAt = now;
  //   return isar.writeTxn(() async {
  //     await isar.diarys.put(diary);
  //   });
  // }
  //
  // /// 日記を更新する
  // Future<void> updateDiary({
  //   required Diary diary,
  //   required String content,
  // }) {
  //   if (!isar.isOpen) {
  //     return Future<void>(() {});
  //   }
  //
  //   final now = DateTime.now();
  //   diary
  //     ..content = content
  //     ..updatedAt = now;
  //   return isar.writeTxn(() async {
  //     await isar.diarys.put(diary);
  //   });
  // }
  //
  // /// 日記を削除する
  // Future<void> deleteDiary({required Diary diary}) async {
  //   if (!isar.isOpen) {
  //     return Future<void>(() {});
  //   }
  //
  //   await isar.writeTxn(() async {
  //     return isar.diarys.delete(diary.id);
  //   });
  // }
}
