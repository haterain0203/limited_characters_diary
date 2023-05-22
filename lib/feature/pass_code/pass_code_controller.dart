import 'pass_code_repository.dart';

class PassCodeController {
  PassCodeController({
    required this.repo,
    required this.invalidatePassCodeProvider,
  });

  final PassCodeRepository repo;
  final void Function() invalidatePassCodeProvider;

  Future<void> savePassCode({
    required String passCode,
    required bool isPassCodeLock,
  }) async {
    await repo.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
    // passCodeProviderの値を再取得
    // パスコード登録した後にアプリをバックグラウンドに移行した際にパスコードロック画麺を表示するため
    // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードONが反映されない
    invalidatePassCodeProvider();
  }
}
