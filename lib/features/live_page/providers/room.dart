import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/features/live_page/dto/bulletin.dart';
import 'package:actpod_web/features/live_page/dto/chat.dart';
import 'package:actpod_web/features/live_page/dto/live_room.dart';
import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:actpod_web/features/live_page/dto/sticker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

final roomInfoProvider = StateProvider<LiveRoomDto?>((ref) => null);
final roomMembersProvider = StateProvider<List<LiveRoomMemberDto>>((ref) => []);
final stickersProvider = StateProvider<List<LiveRoomStickerDto>>((ref) => []);
final storyInfoProvider = StateProvider<GetOneStoryResItem?>((ref) => null);
final bulletinsProvider = StateProvider<List<RoomBulletinDto>>((ref) => []);
final chatMessagesProvider = StateProvider<List<ChatMessageDto>>((ref) => []);
final showFunctionOptionProvider = StateProvider.autoDispose<bool>((ref) => false);
final handsUpProvider = StateProvider<bool>((ref) => false);
final onMicProvider = StateProvider<bool>((ref) => false);

final selectedStickerProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectedStickerDonateAmountProvider = StateProvider.autoDispose<int>((ref) => 0);

final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final isPlayingPodcastProvider = StateProvider<bool>((ref) => false);

final onMicMembersProvider = StateProvider<List<LiveRoomMemberDto>>((ref) => []);
final livekitConnectionStateProvider = StateProvider<ConnectionState>((ref) => ConnectionState.disconnected);

enum InteractiveRoomMode {
  inactive,
  active
}
final interactiveRoomModeProvider = StateProvider<InteractiveRoomMode>((ref) => InteractiveRoomMode.inactive);
