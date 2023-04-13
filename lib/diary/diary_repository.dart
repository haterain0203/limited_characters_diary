import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'diary.dart';

class DiaryRepository {
  DiaryRepository({required this.diaryRef});

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
}
