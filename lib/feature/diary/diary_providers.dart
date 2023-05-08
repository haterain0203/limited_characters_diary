import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/first_launch/first_launch_providers.dart';

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

final isOpenedEditDialogProvider = StateProvider((ref) => false);

/// 起動時に日記入力ダイアログを自動表示するかどうか
final isShowEditDialogOnLaunchProvider = Provider.autoDispose<bool>((ref) {

  // 既に日記表示ダイアログが表示されていたら処理終了
  final isOpenedEditDialog = ref.watch(isOpenedEditDialogProvider);
  if(isOpenedEditDialog) {
    return false;
  }

  // パスコード画面を表示している場合は処理終了
  final isScreenLocked = ref.watch(isOpenedScreenLockProvider);
  if(isScreenLocked) {
    return false;
  }

  // 初回起動時なら処理終了
  final isFirstLaunch = ref.watch(isFirstLaunchProvider);
  if(isFirstLaunch) {
    return false;
  }

  // 日記情報がnullの場合処理終了
  final diaryList = ref.watch(diaryStreamProvider).value;
  if(diaryList == null) {
    return false;
  }

  // 既に当日の日記が入力済みの場合処理終了
  final today = ref.watch(todayProvider);
  final filteredDiary = diaryList.where((element) => element.diaryDate == today).toList();
  if(filteredDiary.isNotEmpty) {
    return false;
  }

  //上記条件をクリアしている場合は、ダイアログを表示させる
  return true;
});
