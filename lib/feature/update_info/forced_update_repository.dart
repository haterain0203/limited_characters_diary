import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateInfoRepository {
  UpdateInfoRepository({required this.updateInfoRef});
  final CollectionReference<UpdateInfo> updateInfoRef;
}
