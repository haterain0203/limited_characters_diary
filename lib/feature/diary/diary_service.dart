import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_repository.dart';

import '../date/date_controller.dart';
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

final diaryStreamProvider = StreamProvider.autoDispose<List<Diary>>((ref) {
  final repo = ref.watch(diaryRepoProvider);
  final selectedDate = ref.watch(selectedDateTimeProvider);
  final diaryList = repo.subscribedDiaryList(selectedMonthDate: selectedDate);
  return diaryList;
});

final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});
