import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/auth_providers.dart';
import '../date/date_controller.dart';
import 'diary.dart';
import 'diary_controller.dart';
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
  return count;
});

final diaryControllerProvider = Provider((ref) => DiaryController(ref: ref));
