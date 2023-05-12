import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_providers.dart';

import '../auth/auth_providers.dart';
import '../date/date_controller.dart';
import '../pass_code/pass_code_providers.dart';
import 'diary.dart';
import 'diary_controller.dart';
import 'diary_repository.dart';

final uidProvider = Provider(
      (ref) => ref.watch(authInstanceProvider).currentUser?.uid,
);

final diaryRepoProvider = Provider(
      (ref) => DiaryRepository(
    diaryRef: ref.watch(diaryRefProvider),
  ),
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
  final selectedMonthDate = ref.watch(selectedMonthDateProvider);
  final diaryList =
  repo.subscribedDiaryList(selectedMonthDate: selectedMonthDate);
  return diaryList;
});

final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});

final diaryControllerProvider = Provider((ref) => DiaryController(ref: ref));

/// 起動時に日記入力ダイアログを自動表示するかどうか
final isShowEditDialogOnLaunchProvider = Provider.autoDispose<bool>((ref) {

  // パスコード画面を表示している場合は処理終了
  final isScreenLocked = ref.watch(isOpenedScreenLockProvider);
  if(isScreenLocked) {
    return false;
  }

  // メンテナンス画面表示中の場合は処理終了
  final updateInfo = ref.watch(updateInfoProvider).value;
  if(updateInfo == null) {
    return false;
  }
  if(updateInfo.isUnderRepair) {
    return false;
  }

  // 強制アップデート表示中の場合は処理終了
  final forcedUpdate = ref.watch(forcedUpdateProvider).value;
  if(forcedUpdate == null) {
    return false;
  }
  if(forcedUpdate) {
    return false;
  }

  // 当月以外の月を表示した際は表示しない
  final today = ref.watch(todayProvider);
  final selectedMonth = ref.watch(selectedMonthDateProvider);
  if(today.month != selectedMonth.month) {
    return false;
  }

  // 日記情報がnullの場合処理終了
  final diaryList = ref.watch(diaryStreamProvider).value;
  if(diaryList == null) {
    return false;
  }

  // 既に当日の日記が入力済みの場合処理終了
  final filteredDiary = diaryList.where((element) => element.diaryDate == today).toList();
  if(filteredDiary.isNotEmpty) {
    return false;
  }

  //上記条件をクリアしている場合は、ダイアログを表示させる
  return true;
});
