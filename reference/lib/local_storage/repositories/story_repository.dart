import '../../dto/story_dto.dart';
import '../../main.dart';
import '../../objectbox.g.dart';

final StoryRepository storyRepository  = StoryRepository(store);

class StoryRepository {
  final Store _store;
  Box<StoryDto>? _storyBox;

  StoryRepository(this._store) {
    _storyBox = Box<StoryDto>(_store);
  }

  int? insertStory(StoryDto voiceMessageDto) {
    return _storyBox?.put(voiceMessageDto);
  }

  List<int>? insertManyStories(List<StoryDto> storyDtoList) {
    return _storyBox?.putMany(storyDtoList);
  }

  List<StoryDto>? getStoriesByUserId(String userId) {
    Query<StoryDto>? query = _storyBox?.query(StoryDto_.userId.equals(userId)).build();
    List<StoryDto>? res = query?.find();
    query?.close();
    return res;
  }

  List<StoryDto>? getStoriesByCollectionId(String collectionId) {
    Query<StoryDto>? query = _storyBox?.query(StoryDto_.collectionId.equals(collectionId)).build();
    List<StoryDto>? res = query?.find();
    query?.close();
    return res;
  }

  int? removeStoriesByUserId(String userId) {
    Query<StoryDto>? query = _storyBox?.query(StoryDto_.userId.equals(userId)).build();
    int? res = query?.remove();
    query?.close();
    return res;
  }

  int? removeStoryByStoryId(String storyId) {
    Query<StoryDto>? query = _storyBox?.query(StoryDto_.storyId.equals(storyId)).build();
    int? res = query?.remove();
    query?.close();
    return res;
  }


  List<StoryDto>? getAllStories() {
    return _storyBox?.getAll();
  }

  int? removeAllStories() {
    return _storyBox?.removeAll();
  }
}