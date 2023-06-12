import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/shared_preferences/shared_preferences_providers.dart';

import 'pass_code.dart';
import 'pass_code_repository.dart';

final passCodeRepositoryProvider = Provider(
  (ref) {
    return PassCodeRepository(
      prefs: ref.watch(sharedPreferencesInstanceProvider),
    );
  },
);

/// PassCodeを取得するProvider
final passCodeProvider = Provider<PassCode>((ref) {
  final repo = ref.watch(passCodeRepositoryProvider);
  final passCode = repo.fetchPassCode();
  return passCode;
});

/// パスコードロック設定をOn/Off状態の取得
final isSetPassCodeLockProvider = Provider<bool>((ref) {
  // 設定でのパスコードロックがOFFなら表示しない
  return ref.watch(passCodeProvider.select((value) => value.isPassCodeEnabled));
});
