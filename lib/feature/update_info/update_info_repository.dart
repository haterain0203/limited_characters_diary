import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';

import '../firestore/firestore_instance_provider.dart';

final updateInfoRepoProvider = Provider(
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

class UpdateInfoRepository {
  UpdateInfoRepository({required this.updateInfoRef});
  final DocumentReference<UpdateInfo> updateInfoRef;

  Stream<UpdateInfo> subscribedUpdateInfo() {
    final snapshots = updateInfoRef.snapshots();
    final updateInfo = snapshots.map((snapshot) {
      return snapshot.data()!;
    });
    return updateInfo;
  }
}
