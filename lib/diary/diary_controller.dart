import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_providers.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

import 'diary.dart';

final uidProvider = Provider(
  (ref) => ref.watch(authInstanceProvider).currentUser?.uid,
);

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
    fireStore: ref.watch(firestoreInstanceProvider),
    uid: ref.watch(uidProvider),
    diaryRef: ref.watch(diaryRefProvider),
  ),
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

final diaryStreamProvider = StreamProvider<List<Diary>>((ref) {
  final repo = ref.read(diaryRepoProvider);
  final diaryList = repo.subscribedDiaryList();
  return diaryList;
});
// // final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());
//
// final diaryRepoProvider = Provider<DiaryRepository>(
//   (ref) {
//     final isar = ref.watch(isarProvider);
//     return DiaryRepository(isar);
//   },
// );
//
// final diaryFutureProvider = FutureProvider<List<Diary>>((ref) async {
//   final diaryRepo = ref.watch(diaryRepoProvider);
//   final selectedMonth = ref.watch(selectedMonthProvider);
//   final diaryList = await diaryRepo.findDiaryList(selectedMonth);
//   return diaryList;
// });

final diaryControllerProvider = Provider((ref) => DiaryController(ref: ref));

class DiaryController {
  DiaryController({required this.ref});
  final ProviderRef<dynamic> ref;

  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    final repo = ref.read(diaryRepoProvider);
    await repo.addDiary();
  }

  // Future<void> addDiary({
  //   required String content,
  //   required DateTime selectedDate,
  // }) async {
  //   final diaryRepo = ref.watch(diaryRepoProvider);
  //   await diaryRepo.addDiary(content: content, selectedDate: selectedDate);
  //   ref.invalidate(diaryFutureProvider);
  // }
  //
  // Future<void> updateDiary({
  //   required Diary diary,
  //   required String content,
  // }) async {
  //   final diaryRepo = ref.watch(diaryRepoProvider);
  //   await diaryRepo.updateDiary(diary: diary, content: content);
  //   ref.invalidate(diaryFutureProvider);
  // }
  //
  // Future<void> deleteDiary({
  //   required Diary diary,
  // }) async {
  //   final diaryRepo = ref.watch(diaryRepoProvider);
  //   await diaryRepo.deleteDiary(diary: diary);
  //   ref.invalidate(diaryFutureProvider);
  // }
}
