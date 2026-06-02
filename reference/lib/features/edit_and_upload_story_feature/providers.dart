import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/find_audios_res.dart';
import 'package:quick_share_app/dto/background_music_dto.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/dto/story_dto.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';

import '../../dto/backgournd_music_list_item_dto.dart';
import '../../dto/sound_effect_list_item_dto.dart';
import '../../dto/space_dto.dart';
import '../../dto/user_info_dto.dart';

final barScaleProvider = StateProvider<double>((ref) => 40.w);

final pagePositionProvider = StateProvider.autoDispose<int>((ref) => 0);
final storyNameInputFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());
final storyDescriptionInputFocusNodeProvider = Provider<FocusNode>((ref) => FocusNode());

final storyImagesProvider = StateProvider<List<File>?>((ref) => null);
final previewStoryProvider = StateProvider<File?>((ref) => null);
final previewPageStoryPlayTimerProvider = StateProvider<Duration>((ref) => Duration.zero);
final previewStoryPlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "paused"); // playing, paused
final storyNameEditingControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController());
final storyDescriptionEditingControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController());
final channelSelectionProvider = StateProvider<String?>((ref) => null);
final spaceSelectionProvider = StateProvider<String?>((ref) => null);
final collaboratorProvider = StateProvider<UserInfoDto?>((ref) => null);
final scheduledProvider = StateProvider<bool>((ref) => false);
final scheduleTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

final uploadStatusProvider = StateProvider.autoDispose<bool>((ref) => false);

final playerStatusProvider = StateProvider.autoDispose<String>((ref) => "stop"); // pausing, playing, stop
final playTimerProvider = StateProvider<Duration>((ref) => Duration.zero);

final soundEffectListProvider = StateProvider<List<SoundEffectListItemDto>>((ref) => []);
final backgroundMusicListProvider = StateProvider<List<BackgroundMusicListItemDto>>((ref) => []);
final channelListProvider = StateProvider<List<ChannelDto>>((ref) => []);
final spaceListProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);
final searchUserListProvider = StateProvider.autoDispose<List<UserInfoDto>?>((ref) => []);

final totalLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final backgroundMusicLengthProvider = StateProvider<Duration>((ref) => Duration.zero);

final selectedBackgroundProvider = StateProvider<List<BackgroundMusicDto>>((ref) => []);
final selectedSoundEffectDtoProvider = StateProvider<List<SoundEffectDto>>((ref) => []);

final infoTagProvider = StateProvider.autoDispose<bool>((ref) => false);

final extractedPreviewPlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "paused"); // playing, paused
final extractedPreviewLengthProvider = StateProvider.autoDispose<Duration>((ref) => const Duration(seconds: 20));
final extractedPreviewPlayTimerProvider = StateProvider((ref) => Duration.zero);
final extractedPreviewStartPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final extractedPreviewEndPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

final blockInfosProvider = StateProvider<List<BlockInfoDto>>((ref) => []);
final trimmedBlocksProvider = StateProvider<List<BlockInfoDto>>((ref) => []); // for go back
final showBlocksProvider = StateProvider<bool>((ref) => false);

final musicPlayerDurationProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final musicPlayerStatusProvider = StateProvider.autoDispose<String>((ref) => "paused");// "paused, playing"
final musicPlayingUrlProvider = StateProvider.autoDispose<String>((ref) => "");

final cutFromProvider = StateProvider<Duration?>((ref) => null);
final cutToProvider = StateProvider<Duration?>((ref) => null);

final isScrollingProvider = StateProvider<bool>((ref) => false);
final isSeekingProvider = StateProvider.autoDispose<bool>((ref) => false);

final soundAudiosProvider = StateProvider<List<FindAudiosResItem>>((ref) => []);
final musicAudiosProvider = StateProvider<List<FindAudiosResItem>>((ref) => []);
final searchAudioTypeProvider = StateProvider<String>((ref) => "actpod"); // actpod, personal
final uploadAudioFilePathProvider = StateProvider.autoDispose<String?>((ref) => null);

final podcoinSettingProvider = StateProvider<int>((ref) => 0);