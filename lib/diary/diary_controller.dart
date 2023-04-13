import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_providers.dart';
import 'package:limited_characters_diary/date/date_controller.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

import 'diary.dart';

final uidProvider = Provider(
  (ref) => ref.watch(authInstanceProvider).currentUser?.uid,
);

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
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
  final repo = ref.watch(diaryRepoProvider);
  final selectedMonthDate = ref.watch(selectedMonthDateProvider);
  final diaryList =
      repo.subscribedDiaryList(selectedMonthDate: selectedMonthDate);
  return diaryList;
});

final diaryCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});

final diaryControllerProvider = Provider((ref) => DiaryController(ref: ref));

class DiaryController {
  DiaryController({required this.ref});

  final ProviderRef<dynamic> ref;

  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    final repo = ref.watch(diaryRepoProvider);
    await repo.addDiary(
      content: content,
      selectedDate: selectedDate,
    );
  }

  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    final repo = ref.watch(diaryRepoProvider);
    await repo.updateDiary(diary: diary, content: content);
  }

  Future<void> deleteDiary({required Diary diary}) async {
    final repo = ref.watch(diaryRepoProvider);
    await repo.deleteDiary(diary: diary);
  }
}
