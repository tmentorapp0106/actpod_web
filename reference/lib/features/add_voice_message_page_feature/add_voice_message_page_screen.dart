import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/components/whole_page_progress.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/components/back_button.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/add_voice_message_controller.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/pages/after_message_page.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/pages/confirm_page.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/pages/pre_message_page.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/providers.dart';
import 'package:quick_share_app/services/cache_service.dart';

import '../../components/whole_page_loading.dart';
import '../../config/color.dart';
import '../../dto/voice_message_dto.dart';
import '../../providers.dart';
import 'controllers/after_message_recorder_controller.dart';
import 'controllers/player_controller.dart';
import 'controllers/pre_message_recorder_controller.dart';

class AddVoiceMessagePageScreen extends ConsumerStatefulWidget {
  final VoiceMessageDto _voiceMessageDto;

  AddVoiceMessagePageScreen(this._voiceMessageDto);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AddVoiceMessagePageScreenState();
  }
}

class AddVoiceMessagePageScreenState extends ConsumerState<AddVoiceMessagePageScreen> {
  PreMessageRecorderController? _preMessageRecorderController;
  AfterMessageRecorderController? _afterMessageRecorderController;
  PlayerController? _playerController;
  AddVoiceMessageController? _addVoiceMessageController;
  final _pageViewController  = PageController(initialPage: 0);
  late final _pages = [
    PreMessagePage(_preMessageRecorderController!, _pageViewController),
    AfterMessagePage(
      _afterMessageRecorderController!,
      widget._voiceMessageDto,
      _preMessageRecorderController!,
      _pageViewController,
      _playerController!
    ),
    ConfirmPage(
      widget._voiceMessageDto,
      _playerController!,
      _addVoiceMessageController!,
      _preMessageRecorderController!,
      _afterMessageRecorderController!
    )
  ];

  AddVoiceMessagePageScreenState();

  @override
  void initState() {
    super.initState();
    _preMessageRecorderController = PreMessageRecorderController(ref);
    _afterMessageRecorderController = AfterMessageRecorderController(ref);
    _playerController = PlayerController(ref, widget._voiceMessageDto);
    _addVoiceMessageController = AddVoiceMessageController(ref, widget._voiceMessageDto);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CacheService.cleanAudioCache();
      initProviders();
    });
  }

  void initProviders() {
    ref.watch(concatedMessageFilePath.notifier).state = null;
  }

  @override
  void dispose() {
    _preMessageRecorderController!.dispose();
    _afterMessageRecorderController!.dispose();
    _playerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WholePageProgress(
      showProvider: loadingProvider,
      percentageProvider: loadingPercentageProvider,
      text: "音檔處理中",
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: ConfigColor.background,
        child:WillPopScope(
          onWillPop: () async {
            if(_pageViewController.page?.round() != 0) {
              _pageViewController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
              return false;
            } else {
              ref.watch(playTimerProvider.notifier).state = Duration.zero;
              return true;
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: ExpandablePageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageViewController,
                    onPageChanged: (page) {
                      ref.watch(pagePositionProvider.notifier).state = page;
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _pages[index];
                    }
                  )
                ),
                Positioned(
                  top: -5.h,
                  right: 5.w,
                  child: closeBtn(),
                ),
                Positioned(
                  top: -5.h,
                  left: 5.w,
                  child: AddVoiceMessageBackButton(_pageViewController)
                )
              ]
            )
         )
        )
      )
    );
  }

  Widget closeBtn() {
    return IconButton(
      icon: Icon(
        Icons.close_rounded,
        color: Colors.black,
      ),
      onPressed: () async {
        ref.watch(playTimerProvider.notifier).state = Duration.zero;
        Navigator.of(context).pop();
      },
    );
  }
}