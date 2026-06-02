
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_progress.dart';
import 'package:quick_share_app/dto/block_info_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/edit_story_screen/back_dialog.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/inquire_saving_draft_dialog.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/extracted_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/extracted_preview_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/music_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/noise_preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/preview_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/preview_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/transition_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/upload_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/card_preview_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/edit_story_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/extract_preview_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/upload_setting_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/title_and_description_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/trim_page.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/noise_providers.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../components/whole_page_loading.dart';
import '../../config/color.dart';
import '../../providers.dart';
import '../../shared_prefs/record_backup_prefs.dart';
import '../login_feature/login_screen.dart';
import 'components/edit_audio_text.dart';
import 'components/confirm_leaving_dialog.dart';
import 'components/step_upload_button.dart';
import 'controllers/edit_trim_player_controller.dart';

class RecordPreviewScreen extends ConsumerStatefulWidget {
  final String? originWavFilePath;
  final String? normalizedM4aFilePath;
  final String? normalizedWavFilePath;
  final String? pickedFilePath;
  final List<double>? waveformData;
  final List<BlockInfoDto>? blockInfoList;
  final bool skipEditPage;
  final String? rssFeedTitle;
  final String? rssFeedDesc;

  RecordPreviewScreen( 
    this.skipEditPage, 
    {
      this.originWavFilePath,
      this.normalizedM4aFilePath,
      this.normalizedWavFilePath,
      this.pickedFilePath,
      this.waveformData, 
      this.blockInfoList,
      this.rssFeedTitle,
      this.rssFeedDesc
    }
  );

  @override
  ConsumerState<RecordPreviewScreen> createState() {
    return RecordPreviewScreenState();
  }

}

class RecordPreviewScreenState extends ConsumerState<RecordPreviewScreen> {
  ScrollController? _storyBarScrollController;
  ScrollController? _soundEffectBarScrollController;
  ScrollController? _backgroundBarScrollController;
  ScrollController? _timerIndicatorScrollController;
  ScrollController? _previewScrollController;
  NoisePreviewPlayerController? _noisePreviewPlayerController;
  EditTrimPlayerTimerController? _editTrimPlayerTimerController;
  MusicPlayerController? _musicPlayerController;
  ListController? _listController;
  EditController? _editController;
  EditTrimPlayController? _editTrimPlayController;
  PreviewPlayerController? _previewPlayerController;
  PreviewPlayerTimerController? _previewPlayerTimerController;
  ExtractedPreviewPlayerController? _extractedPreviewPlayerController;
  ExtractedPreviewPlayerTimerController? _extractedPreviewPlayerTimerController;
  TransitionController? _transitionController;
  UploadController? _uploadController;
  PageController? _pageViewController;
  late final _pages = [
    TrimPage(_editTrimPlayerTimerController, _editTrimPlayController, _storyBarScrollController, _timerIndicatorScrollController, _editController, _noisePreviewPlayerController),
    EditStoryPage(_editTrimPlayerTimerController, _editTrimPlayController, _storyBarScrollController, _soundEffectBarScrollController, _backgroundBarScrollController, _timerIndicatorScrollController, _musicPlayerController, _listController, _uploadController),
    TitleAndDescriptionPage(),
    ExtractPreviewPage(_previewScrollController!, _previewPlayerController!, _previewPlayerTimerController!, _extractedPreviewPlayerController!, _transitionController!),
    PremiumSettingPage(_listController!),
    CardPreviewPage()
  ];

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: widget.skipEditPage? 2 : 0);
    _storyBarScrollController = ScrollController();
    _soundEffectBarScrollController = ScrollController();
    _backgroundBarScrollController = ScrollController();
    _timerIndicatorScrollController = ScrollController();
    _previewScrollController = ScrollController();
    _listController = ListController(ref);
    _editController = EditController(ref);
    _noisePreviewPlayerController = NoisePreviewPlayerController(ref);
    _musicPlayerController = MusicPlayerController(ref);
    _editTrimPlayerTimerController = EditTrimPlayerTimerController(ref, _storyBarScrollController!);
    _editTrimPlayController = EditTrimPlayController(ref, _editTrimPlayerTimerController!);
    _previewPlayerTimerController = PreviewPlayerTimerController(ref, _previewScrollController!);
    _previewPlayerController = PreviewPlayerController(ref, _previewPlayerTimerController!);
    _extractedPreviewPlayerTimerController = ExtractedPreviewPlayerTimerController(ref);
    _extractedPreviewPlayerController = ExtractedPreviewPlayerController(ref, _extractedPreviewPlayerTimerController!);
    _uploadController = UploadController(ref, _editTrimPlayController!, _previewPlayerController!);
    _transitionController = TransitionController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await RecordBackupPrefs.setBackupPath(""); // clean backup(進到這頁代表音檔已經處理好了，沒有儲存草稿是 user 的失誤)
      await RecordBackupPrefs.setBackupWaveformData([]);
      await RecordBackupPrefs.setBackupLength(0);
      initProviders();
      _storyBarScrollController!.addListener(() {
        syncStoryBarScrollControllers();
      });
      if(widget.skipEditPage) {
        ref.watch(pagePositionProvider.notifier).state = 2;
        await _previewPlayerController!.prepareStory(widget.pickedFilePath!, isFromPickedFile: true);
        await _extractedPreviewPlayerController!.prepareStory(widget.pickedFilePath!, isFromPickedFile: true);
      } else {
        await _editTrimPlayController!.prepareStory(widget.originWavFilePath!, widget.normalizedWavFilePath!, widget.waveformData, widget.blockInfoList);
      }
      _editTrimPlayController!.prepareSoundEffect();
      _editTrimPlayController!.prepareBackgroundMusic();
      _listController!.getSpaces();
      _listController!.getChannels();
      _transitionController!.getTransitionList();
      if(UserService.hasLoggedIn()) {
        _listController!.getPersonalMusicAudios();
        _listController!.getPersonalSoundAudios();
      }
    });
  }

  void syncStoryBarScrollControllers() {
    // sync cut window's size
    if(ref.watch(cutFromProvider) != null) {
      if(ref.watch(cutToProvider) != null && Duration(milliseconds: (_storyBarScrollController!.position.pixels * ref.watch(barScaleProvider)).round()) < ref.watch(cutFromProvider)!) {
        ref.watch(cutFromProvider.notifier).state = null;
        ref.watch(cutToProvider.notifier).state = null;
      } else {
        ref.watch(cutToProvider.notifier).state = Duration(milliseconds: (_storyBarScrollController!.position.pixels * ref.watch(barScaleProvider)).round());
      }
    }

    // sync timer scrollview
    _timerIndicatorScrollController!.jumpTo(_storyBarScrollController!.offset);
    if(ref.watch(pagePositionProvider) == 1) {
      _soundEffectBarScrollController!.jumpTo(_storyBarScrollController!.offset);
      _backgroundBarScrollController!.jumpTo(_storyBarScrollController!.offset);
    }
  }

  void initProviders() {
    ref.watch(loadingProvider.notifier).state = false;
    ref.watch(barScaleProvider.notifier).state = 40.w;
    ref.watch(noisePreviewProcessProvider.notifier).state = null;
    ref.watch(storyImagesProvider.notifier).state = null;
    ref.watch(backgroundMusicLengthProvider.notifier).state = Duration.zero;
    ref.watch(selectedSoundEffectDtoProvider.notifier).state = [];
    ref.watch(playTimerProvider.notifier).state = Duration.zero;
    ref.watch(previewStoryProvider.notifier).state = null;
    ref.watch(extractedPreviewStartPositionProvider.notifier).state = Duration.zero;
    ref.watch(extractedPreviewEndPositionProvider.notifier).state = Duration.zero;
    ref.watch(previewPageStoryPlayTimerProvider.notifier).state = Duration.zero;
    ref.watch(storyImagesProvider.notifier).state = null;
    ref.watch(channelSelectionProvider.notifier).state = null;
    ref.watch(spaceSelectionProvider.notifier).state = null;
    ref.watch(isScrollingProvider.notifier).state = false;
    ref.watch(selectedBackgroundProvider.notifier).state = [];
    ref.watch(blockInfosProvider.notifier).state = [];
    ref.watch(trimmedBlocksProvider.notifier).state = [];
    ref.watch(showBlocksProvider.notifier).state = false;
    ref.watch(noisePreviewPlayerDurationProvider.notifier).state = Duration.zero;
    ref.watch(noisePreviewPlayerLengthProvider.notifier).state = Duration.zero;
    ref.watch(noisePreviewPlayerStatusProvider.notifier).state = "paused";
    ref.watch(nrProvider.notifier).state = 11;
    ref.watch(nfProvider.notifier).state = 38;
    ref.watch(soundAudiosProvider.notifier).state = [];
    ref.watch(musicAudiosProvider.notifier).state = [];
    ref.watch(transitionSelectedProvider.notifier).state = null;
    ref.watch(podcoinSettingProvider.notifier).state = 0;
    ref.watch(collaboratorProvider.notifier).state = null;
    ref.watch(storyNameEditingControllerProvider).text = widget.rssFeedTitle ?? "";
    ref.watch(storyDescriptionEditingControllerProvider).text = widget.rssFeedDesc ??"";
    ref.watch(storyDescriptionEditingControllerProvider).text = "";
    ref.watch(scheduleTimeProvider.notifier).state = DateTime.now();
    ref.watch(scheduledProvider.notifier).state = false;
  }

  @override
  void dispose() {
    _storyBarScrollController!.removeListener(syncStoryBarScrollControllers);
    _storyBarScrollController!.dispose();
    _backgroundBarScrollController?.dispose();
    _soundEffectBarScrollController?.dispose();
    _editTrimPlayController!.dispose();
    _previewPlayerController!.dispose();
    _musicPlayerController!.dispose();
    _noisePreviewPlayerController!.dispose();
    super.dispose();
  }

  Future<bool> confirmLeaving() async {
    bool leave = await showDialog(
      context: context,
      builder: (context) {
        return ConfirmLeavingDialog(widget.originWavFilePath, widget.skipEditPage);
      }
    );
    if(leave) {
      return true;
    }
    return false;
  }

  Future<void> onPageChange(int page) async {
    ref.watch(pagePositionProvider.notifier).state = page;
    if(page == 1) { // for animation fluency, delay the render
      await Future.delayed(const Duration(milliseconds: 500));
      ref.watch(showBlocksProvider.notifier).state = true;
    }
    ref.watch(loadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_pageViewController!.page == 1) {
          bool back = await showDialog(
              context: context,
              builder: (context) {
                return BackDialog(_editTrimPlayController!);
              }
          );
          if (back == true) {
            _editTrimPlayerTimerController!.stopTrackingProgress();
            _editTrimPlayController!.seekPosition(0, track: false);
            _pageViewController!.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
          }
          return false;
        }

        if(widget.skipEditPage && _pageViewController!.page!.round() > 2) {
          _pageViewController!.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
          return false;
        } else if(!widget.skipEditPage && _pageViewController!.page?.round() != 0) {
          _pageViewController!.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
          return false;
        } else {
          if(widget.skipEditPage) {
            return await confirmLeaving();
          }
          return true;
        }
      },
      child: WholePageProgress(
        showProvider: loadingProvider,
        percentageProvider: loadingPercentageProvider,
        textColor: Colors.white,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            appBar: AppBar(
              title: EditAudioText(),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: ref.watch(pagePositionProvider) < 2? Colors.white : Colors.black,
                ),
                onPressed: () async {
                  if(_pageViewController!.page == 1) {
                    bool back = await showDialog(
                      context: context,
                      builder: (context) {
                        return BackDialog(_editTrimPlayController!);
                      }
                    );
                    if (back == true) {
                      _editTrimPlayerTimerController!.stopTrackingProgress();
                      _editTrimPlayController!.seekPosition(0, track: false);
                      _pageViewController!.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    }
                    return;
                  }

                  if(widget.skipEditPage && _pageViewController!.page!.round() > 2) {
                    _pageViewController!.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                  } else if(!widget.skipEditPage && _pageViewController!.page?.round() != 0) {
                    _pageViewController!.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                  } else {
                    if(widget.skipEditPage) {
                      if(await confirmLeaving()) {
                        if(context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
              elevation: 0,
              backgroundColor: ref.watch(pagePositionProvider) < 2 && !widget.skipEditPage? Colors.black : Colors.white,
            ),
            backgroundColor: ref.watch(pagePositionProvider) < 2 && !widget.skipEditPage? Colors.black : Colors.white,
            body: Stack(
              children: [
                PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageViewController,
                  onPageChanged: onPageChange,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _pages[index];
                  }
                ),
                Positioned(
                  right: 20.w,
                  bottom: 40.h,
                  child: StepUploadBtn(_pageViewController!, _uploadController!, _editTrimPlayController!, _editTrimPlayerTimerController!, _listController!, _previewPlayerController!, _extractedPreviewPlayerController!),
                )
              ]
            )
          )
        )
      )
    );
  }
}