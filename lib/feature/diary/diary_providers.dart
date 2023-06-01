import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_providers.dart';

import '../auth/auth_providers.dart';
import '../date/date_providers.dart';
import '../update_info/update_info.dart';
import 'diary.dart';
import 'diary_controller.dart';
import 'diary_repository.dart';

final uidProvider = Provider(
  (ref) => ref.watch(authInstanceProvider).currentUser?.uid,
);

final diaryRepoProvider = Provider(
  (ref) => DiaryRepository(
    //TODO check ref.watchが望ましいか？
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

//TODO check Controllerから移動したが、書き方に問題はないか？
final indexDateDiaryProvider =
    Provider.autoDispose.family<Diary?, DateTime>((ref, indexDate) {
  final diaryList = ref.watch(diaryStreamProvider).value ?? [];
  final indexDateDiary = diaryList.firstWhereOrNull((diary) {
    return diary.diaryDate == indexDate;
  });
  return indexDateDiary;
});

final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});

final diaryControllerProvider = Provider(
  (ref) => DiaryController(
    repo: ref.watch(diaryRepoProvider),
  ),
);

/// 既に日記入力ダイアログが表示済みかどうか
final isInputDiaryDialogShownProvider = StateProvider((ref) => false);

//TODO check 記述箇所/記述方法について確認
/// 起動時に日記入力ダイアログを自動表示するかどうか
final isShowInputDiaryDialogOnLaunchProvider =
    Provider.autoDispose<bool>((ref) {
  // 既に日記入力ダイアログが表示済みなら日記ダイアログを自動表示しない
  if (ref.watch(isInputDiaryDialogShownProvider)) {
    return false;
  }

  // メンテナンス中なら日記ダイアログを自動表示しない
  if (_isUnderRepair(updateInfo: ref.watch(updateInfoProvider).value)) {
    return false;
  }

  // 強制アップデート表示中の場合は日記ダイアログを自動表示しない
  if (_isForcedUpdate(isForcedUpdate: ref.watch(forcedUpdateProvider).value)) {
    return false;
  }

  // 当月以外の月を表示した際は表示しない
  final today = ref.watch(todayProvider);
  final selectedMonth = ref.watch(selectedMonthDateProvider);
  if (today.month != selectedMonth.month) {
    return false;
  }

  // 日記情報がnullの場合処理終了
  final diaryList = ref.watch(diaryStreamProvider).value;
  if (diaryList == null) {
    return false;
  }

  // 既に当日の日記が入力済みの場合処理終了
  final filteredDiary =
      diaryList.where((element) => element.diaryDate == today).toList();
  if (filteredDiary.isNotEmpty) {
    return false;
  }

  // ユーザーデータ削除時には表示しない
  //TODO check このフラグが必要になる構造自体に問題がありそう
  // ユーザーデータ削除 → userがnullになる → AuthPageがリビルドする → ListPageがreturnされる → ListPageのuseEffectが実行 → 日記入力ダイアログが表示される
  // という流れだが、ユーザー削除は設定画面から行われ、削除時にはListPageが表示されないため（Phoenixによって再起動されるために最終的にはListPageが呼ばれるが）、
  // ListPageが呼び出される流れ自体に問題がありそう
  final isUserDeleted = ref.watch(isUserDeletedProvider);
  if (isUserDeleted) {
    return false;
  }

  //上記条件をクリアしている場合は、ダイアログを表示させる
  return true;
});

bool _isUnderRepair({required UpdateInfo? updateInfo}) {
  if (updateInfo != null && updateInfo.isUnderRepair) {
    return true;
  }
  return false;
}

bool _isForcedUpdate({required bool? isForcedUpdate}) {
  if (isForcedUpdate != null && isForcedUpdate) {
    return true;
  }
  return false;
}
