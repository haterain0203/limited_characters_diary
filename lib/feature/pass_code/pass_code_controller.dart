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
    //TODO エラーハンドリング
    await repo.savePassCode(
      passCode: passCode,
      isPassCodeLock: isPassCodeLock,
    );
    // passCodeProviderの値を再取得
    // パスコード登録orOFFした際、設定を即時反映させるため
    // ここで再取得しないと、次にアプリが新たに起動されるまでパスコードON/OFFが反映されない
    invalidatePassCodeProvider();
  }
}
