import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/diary/diary_repository.dart';

import '../auth/auth_controller.dart';
import '../date/date_controller.dart';
import '../update_info/update_info_service.dart';
import 'diary.dart';
import 'diary_controller.dart';

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
  final selectedMonthDateTime = ref.watch(selectedMonthDateTimeProvider);
  final diaryList = repo.subscribedDiaryList(selectedMonthDate: selectedMonthDateTime);
  return diaryList;
});

final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});

/// 起動時に日記入力ダイアログを自動表示するかどうか
final shouldShowInputDiaryDialogOnLaunchProvider =
    Provider.autoDispose<bool>((ref) {
  // 既に日記入力ダイアログが表示済みなら日記ダイアログを自動表示しない
  if (ref.watch(hasInputDiaryDialogShownProvider)) {
    return false;
  }

  // 退会処理実行後なら日記ダイアログを自動表示しない
  if (ref.watch(isUserDeletedProvider)) {
    return false;
  }

  final diaryList = ref.watch(diaryStreamProvider);
  final shouldForcedUpdate = ref.watch(shouldForceUpdateProvider);
  final updateInfo = ref.watch(updateInfoProvider);

  // FutureProvider/StreamProviderがAsyncDataではない場合（AsyncLoading or AsyncErrorの場合）、falseを返して処理終了
  if (diaryList is! AsyncData ||
      shouldForcedUpdate is! AsyncData ||
      updateInfo is! AsyncData) {
    return false;
  }

  // 既に当日の日記が入力済みの場合は、日記入力ダイアログを表示しない
  if (hasTodayDiaryAlreadyExists(diaryList.value)) {
    return false;
  }

  // メンテナンス中なら日記ダイアログを自動表示しない
  if (updateInfo.value?.isUnderRepair ?? false) {
    return false;
  }

  // 強制アップデート表示中の場合は日記ダイアログを自動表示しない
  if (shouldForcedUpdate.value ?? false) {
    return false;
  }

  return true;
});

bool hasTodayDiaryAlreadyExists(List<Diary>? diaryList) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayDiary =
      diaryList?.firstWhereOrNull((element) => element.diaryDate == today);
  return todayDiary != null;
}
