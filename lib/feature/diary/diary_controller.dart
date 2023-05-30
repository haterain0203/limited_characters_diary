import 'package:limited_characters_diary/feature/diary/diary_repository.dart';

import 'diary.dart';

class DiaryController {
  DiaryController({required this.repo});
  final DiaryRepository repo;

  //TODO エラーハンドリング
  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    await repo.addDiary(
      content: content,
      selectedDate: selectedDate,
    );
  }

  //TODO エラーハンドリング
  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    await repo.updateDiary(diary: diary, content: content);
  }

  //TODO エラーハンドリング
  Future<void> deleteDiary({required Diary diary}) async {
    await repo.deleteDiary(diary: diary);
  }
}
