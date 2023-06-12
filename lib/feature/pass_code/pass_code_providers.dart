import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'pass_code.dart';
import 'pass_code_repository.dart';

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
