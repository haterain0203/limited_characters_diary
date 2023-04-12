import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_providers.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

import 'diary.dart';

final uidProvider = Provider(
  (ref) => ref.read(authInstanceProvider).currentUser?.uid,
);

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
    fireStore: ref.read(firestoreInstanceProvider),
    uid: ref.read(uidProvider),
  ),
);

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
