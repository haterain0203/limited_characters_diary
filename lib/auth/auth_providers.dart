import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/auth/auth_controller.dart';
import 'package:limited_characters_diary/auth/auth_repository.dart';

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);

final firestoreInstanceProvider = Provider((ref) => FirebaseFirestore.instance);

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.read(authInstanceProvider),
    firestore: ref.read(firestoreInstanceProvider),
  ),
);

final userStateProvider = StreamProvider(
  (ref) {
    return ref.watch(authRepoProvider).authStateChanges();
  },
);

final authControllerProvider = Provider(
  (ref) => AuthController(
    repo: ref.read(authRepoProvider),
  ),
);
