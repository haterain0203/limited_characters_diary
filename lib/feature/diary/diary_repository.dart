import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'diary.dart';
import 'diary_service.dart';

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
    //TODO check ref.watchが望ましいか？
    diaryRef: ref.watch(diaryRefProvider),
  ),
);

class DiaryRepository {
  DiaryRepository({required this.diaryRef});

  final CollectionReference<Diary> diaryRef;

  Stream<List<Diary>> subscribedDiaryList({
    required DateTime selectedMonthDate,
  }) {
    final startDate = DateTime(selectedMonthDate.year, selectedMonthDate.month);
    final endDate =
        DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);
    final snapshots = diaryRef
        .where('diaryDate', isGreaterThanOrEqualTo: startDate)
        .where('diaryDate', isLessThanOrEqualTo: endDate)
        .snapshots();
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
    final id = const Uuid().v4();
    final now = DateTime.now();
    final diary = Diary(
      id: id,
      content: content,
      diaryDate: selectedDate,
      createdAt: now,
      updatedAt: now,
    );
    await diaryRef.doc(id).set(diary);
  }

  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    await diaryRef.doc(diary.id).update({
      'content': content,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deleteDiary({required Diary diary}) async {
    await diaryRef.doc(diary.id).delete();
  }

  // DiaryCollectionのドキュメント数を取得する
  Future<int> getDiaryCount() async {
    final query = diaryRef.count();
    final snap = await query.get();
    return snap.count;
  }
}
