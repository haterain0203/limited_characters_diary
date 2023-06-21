import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/component/dialog_utils.dart';
import 'package:limited_characters_diary/in_app_review/in_app_review_service.dart';

final inAppReviewController = Provider.autoDispose(
  (ref) {
    return InAppReviewController(
      service: ref.watch(inAppReviewServiceProvider),
      dialogUtilsController: ref.watch(dialogUtilsControllerProvider),
    );
  },
);

class InAppReviewController {
  InAppReviewController({
    required this.service,
    required this.dialogUtilsController,
  });

  final InAppReviewService service;
  final DialogUtilsController dialogUtilsController;

  Future<void> requestReview() async {
    try {
      await service.requestReview();
    } on Exception catch (e) {
      debugPrint(e.toString());
      await dialogUtilsController.showErrorDialog(
        errorDetail: e.toString(),
      );
    }
  }

  Future<void> openStore() async {
    try {
      await service.openStore();
    } on Exception catch (e) {
      debugPrint(e.toString());
      await dialogUtilsController.showErrorDialog(
        errorDetail: e.toString(),
      );
    }
  }
}
