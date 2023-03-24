import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:limited_characters_diary/diary/collection/diary.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

final diaryRepoProvider = Provider.family<DiaryRepository, Isar>(
  (ref, isar) => DiaryRepository(isar),
);

final isarProvider = StateProvider<Isar?>((ref) => null);

final diaryFutureProvider = FutureProvider<List<Diary>>((ref) async {
  final isar = ref.watch(isarProvider);
  final diaryRepo = ref.watch(diaryRepoProvider(isar!));
  final diaryList = await diaryRepo.findDiaryList();
  return diaryList;
});

class DiaryController {}
