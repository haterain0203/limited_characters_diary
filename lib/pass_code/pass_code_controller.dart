import 'package:limited_characters_diary/pass_code/pass_code_repository.dart';

class PassCodeController {
  PassCodeController({required this.repo});
  final PassCodeRepository repo;

  Future<void> savePassCode(String passCode) async {
    await repo.savePassCode(passCode);
  }

}
