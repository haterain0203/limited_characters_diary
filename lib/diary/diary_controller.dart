import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:limited_characters_diary/date/date_controller.dart';
import 'package:limited_characters_diary/diary/collection/diary.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final diaryRepoProvider = Provider<DiaryRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return DiaryRepository(isar);
  },
);

final diaryFutureProvider = FutureProvider<List<Diary>>((ref) async {
  final diaryRepo = ref.watch(diaryRepoProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final diaryList = await diaryRepo.findDiaryList(selectedMonth);
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

  Future<void> updateDiary({
    required Diary diary,
    required String content,
  }) async {
    final diaryRepo = ref.watch(diaryRepoProvider);
    await diaryRepo.updateDiary(diary: diary, content: content);
    ref.invalidate(diaryFutureProvider);
  }
}
