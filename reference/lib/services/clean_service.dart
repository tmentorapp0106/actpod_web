import 'package:quick_share_app/local_storage/repositories/board_story_repository.dart';
import 'package:quick_share_app/local_storage/repositories/notification_voice_message_repository.dart';
import 'package:quick_share_app/local_storage/repositories/story_recommendation_repository.dart';
import 'package:quick_share_app/local_storage/repositories/story_repository.dart';

class CleanService {
  static Future<void> cleanLocalStorage() async {
    storyRepository.removeAllStories();
    boardStoryRepository.removeAllBoardStories();
    notificationVoiceMessageRepository.removeAllMessages();
    storyRecommendationRepository.removeAllStoryRecommendations();
  }
}