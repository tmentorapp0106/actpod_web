import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/feed.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/upload_method_bottom_model.dart';

import '../../../../providers.dart';
import '../../../../services/load_file_service.dart';
import '../../../../services/user_service.dart';
import '../../../../utils/audio_utils.dart';
import '../../../edit_and_upload_story_feature/edit_and_upload_story_screen.dart';
import '../../../login_feature/login_screen.dart';
import '../../controllers/feed_controller.dart';
import '../../providers/providers.dart';
import 'feed_list_bottom_model.dart';

class UploadButton extends ConsumerWidget {
  final FeedController feedController;

  UploadButton(this.feedController);

  void uploadFromDevice(WidgetRef ref, BuildContext context) async {
    ref.watch(loadingProvider.notifier).state = true;
    ref.watch(loadingPercentageProvider.notifier).state = null;
    File? file = await LoadFileService.loadAudioFile(
      progressFunction: (percentage){
        ref.watch(loadingPercentageProvider.notifier).state = (percentage * 100).toInt();
      }
    );
    if(file == null) {
      ref.watch(loadingProvider.notifier).state = false;
      ref.watch(loadingPercentageProvider.notifier).state = null;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
    ref.watch(loadingPercentageProvider.notifier).state = null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RecordPreviewScreen(
          true,
          pickedFilePath: file.path,
          waveformData: const []
        )
      ),
    );
  }

  void uploadFromRss(WidgetRef ref, BuildContext context) async {
    feedController.isSynced();
    RssFeed? selectedFeed = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FeedListBottomModel(feedController);
      },
    );
    if(selectedFeed == null) {
      return;
    }

    ref.watch(loadingProvider.notifier).state = true;
    ref.watch(loadingPercentageProvider.notifier).state = null;
    String path;
    try {
      path = await AudioUtils.downloadAudioFileWithProgress(
        selectedFeed.audioUrl,
        onProgress: (progress) {
          ref.watch(loadingPercentageProvider.notifier).state = (progress * 100).toInt();
        }
      );
    } catch(e) {
      ref.watch(loadingPercentageProvider.notifier).state = null;
      ref.watch(loadingProvider.notifier).state = false;
      ref.watch(rssFeedProvider.notifier).state = [];
      return;
    }

    if(path.isEmpty) {
      ref.watch(loadingProvider.notifier).state = false;
      ref.watch(loadingPercentageProvider.notifier).state = null;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
    ref.watch(loadingPercentageProvider.notifier).state = null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RecordPreviewScreen(
          true,
          pickedFilePath: path,
          waveformData: const [],
          rssFeedTitle: selectedFeed.title,
          rssFeedDesc: selectedFeed.desc,
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordStatus = ref.watch(recordStatusProvider);
    final size = 240.w;
    final ringThickness = 14.w;
    return Visibility(
      visible: recordStatus == "pending",
      child: Container(
        margin: EdgeInsets.only(top: 92.h),
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33FFA800),
              blurRadius: 30,
              spreadRadius: 1,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,         // clip ripple to circle
          child: InkWell(
            customBorder: const CircleBorder(), // circular splash
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            onTap: () async {
              if (!UserService.hasLoggedIn()) {
                showDialog(context: context, builder: (_) => LoginPageScreen());
                return;
              }
              final uploadMethod = await showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => UploadMethodBottomModel(),
              );

              if (!context.mounted) return;

              if (uploadMethod == "device") {
                uploadFromDevice(ref, context);
              } else if (uploadMethod == "rss") {
                uploadFromRss(ref, context);
              }
            },
            child: Ink(
              width: size - ringThickness * 2,
              height: size - ringThickness * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFB61D),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.upload_rounded, color: Colors.white, size: 36),
                  SizedBox(height: 10),
                  Text(
                    '上傳音檔',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}