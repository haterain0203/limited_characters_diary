import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:limited_characters_diary/constant/constant_string.dart';

final inAppReviewServiceProvider = Provider.autoDispose((ref) {
  return InAppReviewService(
    inAppReview: ref.watch(inAppReviewInstanceProvider),
  );
});

final inAppReviewInstanceProvider = Provider((ref) {
  return InAppReview.instance;
});

class InAppReviewService {
  InAppReviewService({
    required this.inAppReview,
  });

  final InAppReview inAppReview;

  Future<void> requestReview() async {
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  Future<void> openStore() async {
    await inAppReview.openStoreListing(appStoreId: ConstantString.appStoreId,);
  }
}
