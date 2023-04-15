import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';
import 'package:limited_characters_diary/feature/update_info/update_info_repository.dart';

import '../auth/auth_providers.dart';

final updateRepoProvider = Provider(
  (ref) => UpdateInfoRepository(
    updateInfoRef: ref.watch(updateInfoRefProvider),
  ),
);

final updateInfoRefProvider = Provider((ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final updateInfoRef = firestore
      .collection('update_info')
      .doc('update_info')
      .withConverter<UpdateInfo>(
        fromFirestore: (snapshot, _) => UpdateInfo.fromJson(snapshot.data()!),
        toFirestore: (updateInfo, _) => updateInfo.toJson(),
      );
  return updateInfoRef;
});

final updateInfoProvider = StreamProvider.autoDispose<UpdateInfo>((ref) {
  final repo = ref.watch(updateRepoProvider);
  final updateInfo = repo.subscribedUpdateInfo();
  return updateInfo;
});

final forcedUpdateProvider = FutureProvider.autoDispose<bool>((ref) async {
  //TODO selectを使用すべきか？
  //この書き方だと、FirestoreのUpdateInfoのforcedUpdate以外が更新された場合も処理が走ってしまうのでは？
  final updateInfo = ref.watch(updateInfoProvider);
  if (updateInfo.value == null) {
    return false;
  }
  final repo = ref.watch(updateRepoProvider);
  final requiredUpdate = await repo.requiredUpdate(updateInfo.value!);
  return requiredUpdate;
});
