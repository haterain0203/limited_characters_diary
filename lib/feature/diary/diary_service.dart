import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_providers.dart';
import 'package:limited_characters_diary/feature/diary/diary_repository.dart';

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
