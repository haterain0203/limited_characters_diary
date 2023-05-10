import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/fcm/fcm_providers.dart';

import 'auth_controller.dart';
import 'auth_repository.dart';

final authInstanceProvider = Provider((ref) => FirebaseAuth.instance);

final firestoreInstanceProvider = Provider((ref) => FirebaseFirestore.instance);

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.read(authInstanceProvider),
    firestore: ref.read(firestoreInstanceProvider),
    fcm: ref.read(fcmInstanceProvider),
  ),
);

final userStateProvider = StreamProvider<User?>(
  (ref) {
    final repo = ref.read(authRepoProvider);
    return repo.authStateChanges();
  },
);

final authControllerProvider = Provider(
  (ref) => AuthController(
    repo: ref.read(authRepoProvider),
  ),
);
