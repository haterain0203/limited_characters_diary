import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_repository.dart';
import '../firestore/firestore_instance_provider.dart';
import 'diary.dart';

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
    diaryRef: ref.watch(diaryRefProvider),
  ),
);

final uidProvider = Provider(
  (ref) => ref.watch(authInstanceProvider).currentUser?.uid,
);

final diaryRefProvider = Provider((ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final uid = ref.watch(uidProvider);
  final diaryRef = firestore
      .collection('users')
      .doc(uid)
      .collection('diaryList')
      .withConverter<Diary>(
        fromFirestore: (snapshot, _) => Diary.fromJson(snapshot.data()!),
        toFirestore: (diary, _) => diary.toJson(),
      );
  return diaryRef;
});

class DiaryRepository {
  DiaryRepository({required this.diaryRef});

  final CollectionReference<Diary> diaryRef;

  Stream<List<Diary>> subscribedDiaryList({
    required DateTime selectedMonthDateTime,
  }) {
    final startDate = DateTime(
      selectedMonthDateTime.year,
      selectedMonthDateTime.month,
    );
    final endDate = DateTime(
      selectedMonthDateTime.year,
      selectedMonthDateTime.month + 1,
      0,
    );
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
  Future<int?> getDiaryCount() async {
    final query = diaryRef.count();
    final snap = await query.get();
    return snap.count;
  }
}
