import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'diary.dart';
import 'diary_providers.dart';

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
