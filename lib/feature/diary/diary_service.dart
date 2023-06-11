import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_repository.dart';

import '../auth/auth_controller.dart';
import '../date/date_controller.dart';
import '../firestore/firestore_instance_provider.dart';
import 'diary.dart';

final diaryServiceProvider =
    Provider((ref) => DiaryService(repo: ref.watch(diaryRepoProvider)));

class DiaryService {
  DiaryService({
    required this.repo,
  });

  final DiaryRepository repo;

  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    await repo.addDiary(
      content: content,
      selectedDate: selectedDate,
    );
  }

  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    await repo.updateDiary(diary: diary, content: content);
  }

  Future<void> deleteDiary({required Diary diary}) async {
    await repo.deleteDiary(diary: diary);
  }
}

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

final diaryStreamProvider = StreamProvider.autoDispose<List<Diary>>((ref) {
  final repo = ref.watch(diaryRepoProvider);
  final selectedDate = ref.watch(selectedDateTimeProvider);
  final diaryList = repo.subscribedDiaryList(selectedMonthDate: selectedDate);
  return diaryList;
});

//TODO 日記の数は日記入力完了後のダイアログ表示時にのみ使用するため、常に監視する必要はないが、Controller側に記述した方が良いか？
//TODO ただしその場合、Future<int>を返すことになるので、UI側で待機する処理を別途実装しなければ行けなくなるのでは？
final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});
