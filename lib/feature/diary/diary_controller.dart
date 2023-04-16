import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/auth_providers.dart';
import '../date/date_controller.dart';
import 'diary.dart';
import 'diary_repository.dart';

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

final diaryStreamProvider = StreamProvider.autoDispose<List<Diary>>((ref) {
  final repo = ref.watch(diaryRepoProvider);
  final selectedMonthDate = ref.watch(selectedMonthDateProvider);
  final diaryList =
      repo.subscribedDiaryList(selectedMonthDate: selectedMonthDate);
  return diaryList;
});

final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  print('count@Provider = $count');
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
