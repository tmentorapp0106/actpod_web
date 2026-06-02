import 'package:in_app_review/in_app_review.dart';
import 'package:quick_share_app/shared_prefs/rating_prefs.dart';

class ReviewRatingService {
  static Future<void> ratingForFirstTime() async {
    if(RatingPrefs.alreadyRated()?? false) {
      return;
    }
    if(await InAppReview.instance.isAvailable()) {
      InAppReview.instance.requestReview();
      RatingPrefs.setRated(true);
    }
  }
}