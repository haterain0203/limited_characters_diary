import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/feature/setting/setting_service.dart';

final settingControllerProvider = Provider.autoDispose(
  (ref) => SettingController(service: ref.watch(settingServiceProvider)),
);

class SettingController {
  const SettingController({required this.service});

  final SettingService service;

  Future<String> createContactUsUrl() async {
    return service.createContactUsUrl();
  }
}
