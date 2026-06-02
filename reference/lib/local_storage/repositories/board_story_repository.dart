import '../../dto/space_story_dto.dart';
import '../../main.dart';
import '../../objectbox.g.dart';

final BoardStoryRepository boardStoryRepository  = BoardStoryRepository(store);

class BoardStoryRepository {
  final Store _store;
  Box<SpaceStoryDto>? _boardStoryBox;

  BoardStoryRepository(this._store) {
    _boardStoryBox = Box<SpaceStoryDto>(_store);
  }

  int? insertBoardStory(SpaceStoryDto recommendationItem) {
    return _boardStoryBox?.put(recommendationItem);
  }

  List<int>? insertManyBoardStories(List<SpaceStoryDto> recommendationList) {
    return _boardStoryBox?.putMany(recommendationList);
  }


  List<SpaceStoryDto>? getByBoardId(String boardId) {
    final query = _boardStoryBox?.query(SpaceStoryDto_.spaceId.equals(boardId)).build();
    return query?.find();
  }

  List<SpaceStoryDto>? getAllBoardStories() {
    return _boardStoryBox?.getAll();
  }

  int? removeByBoardId(String boardId) {
    final query = _boardStoryBox?.query(SpaceStoryDto_.spaceId.equals(boardId)).build();
    return query?.remove();
  }

  int? removeByStoryId(String storyId) {
    final query = _boardStoryBox?.query(SpaceStoryDto_.storyId.equals(storyId)).build();
    return query?.remove();
  }

  int? removeAllBoardStories() {
    return _boardStoryBox?.removeAll();
  }

  void updateBoardStoryVoiceMessageStatus(String storyId, String voiceMessageStatus) {
    final query = _boardStoryBox?.query(SpaceStoryDto_.storyId.equals(storyId)).build();
    SpaceStoryDto? boardStoryDto = query?.findFirst();
    if(boardStoryDto != null) {
      boardStoryDto.voiceMessageStatus = voiceMessageStatus;
      _boardStoryBox?.put(boardStoryDto);
    }
  }
}