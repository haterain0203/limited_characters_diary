import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code.dart';
import 'package:limited_characters_diary/feature/pass_code/pass_code_repository.dart';

final passCodeServiceProvider = Provider(
  (ref) => PassCodeService(
    repo: ref.watch(passCodeRepositoryProvider),
  ),
);

class PassCodeService {
  PassCodeService({
    required this.repo,
  });

  final PassCodeRepository repo;

  Future<void> savePassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) async {
    await repo.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
  }
}

/// PassCodeを取得するProvider
final passCodeProvider = Provider<PassCode>((ref) {
  final repo = ref.watch(passCodeRepositoryProvider);
  final passCode = repo.fetchPassCode();
  return passCode;
});

/// パスコードロック設定をOn/Off状態の取得
final passCodeLockToggleProvider = Provider<bool>((ref) {
  // 設定でのパスコードロックがOFFなら表示しない
  return ref.watch(passCodeProvider.select((value) => value.isPassCodeEnabled));
});
