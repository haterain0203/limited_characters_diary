import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_providers.dart';

import '../auth/auth_controller.dart';
import '../date/date_controller.dart';
import '../firestore/firestore_instance_provider.dart';
import 'diary.dart';
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
  final selectedDate = ref.watch(selectedDateTimeProvider);
  final diaryList = repo.subscribedDiaryList(selectedMonthDate: selectedDate);
  return diaryList;
});

//TODO 日記の数は日記入力完了後のダイアログ表示時にのみ使用するため、常に監視する必要はないが、Controller側に記述した方が良いか？
//TODO ただしその場合、Future<int>を返すことになるので、UI側で待機する処理を別途実装しなければ行けなくなるのでは？
final diaryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(diaryRepoProvider);
  final count = await repo.getDiaryCount();
  return count;
});

/// 既に日記入力ダイアログが表示済みかどうか
final isInputDiaryDialogShownProvider = StateProvider((ref) => false);

//TODO check 記述箇所/記述方法について確認
/// 起動時に日記入力ダイアログを自動表示するかどうか
final isShowInputDiaryDialogOnLaunchProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  // 既に日記入力ダイアログが表示済みなら日記ダイアログを自動表示しない
  if (ref.watch(isInputDiaryDialogShownProvider)) {
    return false;
  }

  // 当月以外の月を表示した際は表示しない
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedDate = ref.watch(selectedDateTimeProvider);
  if (today.month != selectedDate.month) {
    return false;
  }

  // 日記情報がnullの場合=日記情報取得中の場合は、日記入力ダイアログを表示しない
  final diaryList = ref.watch(diaryStreamProvider).value;
  if (diaryList == null) {
    return false;
  }

  // 既に当日の日記が入力済みの場合は、日記入力ダイアログを表示しない
  final todayDiary =
      diaryList.firstWhereOrNull((element) => element.diaryDate == today);
  if (todayDiary != null) {
    return false;
  }

  // メンテナンス中なら日記ダイアログを自動表示しない
  if (ref.watch(updateInfoProvider).value?.isUnderRepair == true) {
    return false;
  }

  // 強制アップデート表示中の場合は日記ダイアログを自動表示しない
  if (await ref.watch(forcedUpdateProvider.future)) {
    return false;
  }

  // ユーザーデータ削除時には表示しない
  //TODO check このフラグが必要になる構造自体に問題がありそう
  // ユーザーデータ削除 → userがnullになる → AuthPageがリビルドする → ListPageがreturnされる → ListPageのuseEffectが実行 → 日記入力ダイアログが表示される
  // という流れだが、ユーザー削除は設定画面から行われ、削除時にはListPageが表示されないため（Phoenixによって再起動されるために最終的にはListPageが呼ばれるが）、
  // ListPageが呼び出される流れ自体に問題がありそう
  if (ref.watch(isUserDeletedProvider)) {
    return false;
  }

  //上記条件をクリアしている場合は、ダイアログを表示させる
  return true;
});
