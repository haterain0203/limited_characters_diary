import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firestoreInstanceProvider = Provider((ref) => FirebaseFirestore.instance);
