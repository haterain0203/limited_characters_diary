import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:limited_characters_diary/feature/update_info/update_info.dart';

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
