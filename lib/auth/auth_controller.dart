import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:limited_characters_diary/auth/auth_repository.dart';

class AuthController {
  AuthController({
    required this.repo,
    required this.auth,
    required this.firestore,
  });
  final AuthRepository repo;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Future<void> signInAnonymously() {
    return repo.signInAnonymously(auth, firestore);
  }
}
