import 'package:flutter_riverpod/legacy.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:quick_share_app/dto/live_room_background_music_dto.dart';
import 'package:quick_share_app/dto/live_room_dto.dart';
import 'package:quick_share_app/dto/live_room_member_dto.dart';
import 'package:quick_share_app/dto/live_room_sticker_dto.dart';
import 'package:quick_share_app/dto/room_bulletin_dto.dart';
import 'package:quick_share_app/features/live_feature/dto/chat_message_dto.dart';

import '../../apiManagers/story_api_dto/get_one_story_res.dart';

final storyInfoProvider = StateProvider<GetOneStoryResItem?>((ref) => null);
final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final roomMembersProvider = StateProvider<List<LiveRoomMemberDto>>((ref) => []);
final chatMessagesProvider = StateProvider<List<ChatMessageDto>>((ref) => []);
enum PodcastPlayerStatus {
  playing,
  paused,
  initializing
}
final podcastPlayerStatusProvider = StateProvider<PodcastPlayerStatus>((ref) => PodcastPlayerStatus.initializing);
final roomInfoProvider = StateProvider<LiveRoomDto?>((ref) => null);

enum InteractiveRoomMode {
  inactive,
  active
}
final interactiveRoomModeProvider = StateProvider<InteractiveRoomMode>((ref) => InteractiveRoomMode.inactive);
final onMicMembersProvider = StateProvider<List<LiveRoomMemberDto>>((ref) => []);
final onMicProvider = StateProvider<bool>((ref) => false);
final handsUpProvider = StateProvider<bool>((ref) => false);
final showFunctionOptionProvider = StateProvider.autoDispose<bool>((ref) => false);
final livekitConnectionStateProvider = StateProvider<ConnectionState>((ref) => ConnectionState.disconnected);

final bulletinsProvider = StateProvider<List<RoomBulletinDto>>((ref) => []);

final stickersProvider = StateProvider<List<LiveRoomStickerDto>>((ref) => []);
final selectedStickerProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectedStickerDonateAmountProvider = StateProvider.autoDispose<int>((ref) => 0);

final backgroundMusicsProvider = StateProvider<List<LiveRoomBackgroundMusicDto>>((ref) => []);
final playingBackgroundMusicUrlProvider = StateProvider<String>((ref) => "");

final activeRoomsProvider = StateProvider<List<LiveRoomDto>?>((ref) => null);

final isCollectedProvider = StateProvider<bool?>((ref) => null);

final isHostedProvider = StateProvider<bool?>((ref) => null);