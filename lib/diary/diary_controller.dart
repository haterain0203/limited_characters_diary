import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:limited_characters_diary/diary/diary_repository.dart';

final diaryRepoProvider = Provider.family<DiaryRepository, Isar>(
    (ref, isar) => DiaryRepository(isar));

final diaryFutureProvider = FutureProvider((ref) async {});

class DiaryController {}
