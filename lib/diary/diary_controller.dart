import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:limited_characters_diary/diary/collection/diary.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

final diaryRepoProvider = Provider<DiaryRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    //TODO
    return DiaryRepository(isar!);
  },
);

final isarProvider = StateProvider<Isar?>((ref) => null);

final diaryFutureProvider = FutureProvider<List<Diary>>((ref) async {
  final diaryRepo = ref.watch(diaryRepoProvider);
  final diaryList = await diaryRepo.findDiaryList();
  return diaryList;
});

final diaryControllerProvider = Provider((ref) => DiaryController(ref: ref));

class DiaryController {
  DiaryController({required this.ref});
  final ProviderRef<dynamic> ref;

  Future<void> addDiary({
    required String content,
    required DateTime selectedDate,
  }) async {
    final diaryRepo = ref.watch(diaryRepoProvider);
    await diaryRepo.addDiary(content: content, selectedDate: selectedDate);
    ref.invalidate(diaryFutureProvider);
  }
}
