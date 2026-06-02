import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/feed.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/feed_list_bottom_model.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/upload_method_bottom_model.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/load_file_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/audio_utils.dart';

import '../../../edit_and_upload_story_feature/controllers/edit_controller.dart';
import '../../../login_feature/login_screen.dart';
import '../../providers/providers.dart';
import '../../../edit_and_upload_story_feature/edit_and_upload_story_screen.dart';

class UploadFileBtn extends ConsumerWidget {
  final FeedController feedController;

  UploadFileBtn(this.feedController);

  void uploadFromDevice(WidgetRef ref, BuildContext context) async {
    ref.watch(loadingProvider.notifier).state = true;
    File? file = await LoadFileService.loadAudioFile(
      progressFunction: (progress){}
    );
    if(file == null) {
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
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
    RssFeed? selectedRss = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FeedListBottomModel(feedController);
      },
    );
    if(selectedRss == null) {
      return;
    }

    ref.watch(loadingProvider.notifier).state = true;
    String path = await AudioUtils.downloadAudioFile(selectedRss.audioUrl);
    if(path.isEmpty) {
      ref.watch(loadingProvider.notifier).state = false;
      return;
    }
    ref.watch(loadingProvider.notifier).state = false;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RecordPreviewScreen( 
          true,
          pickedFilePath: path,
          waveformData: const [],
          rssFeedTitle: selectedRss.title,
          rssFeedDesc: selectedRss.desc,
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      maintainSize: ref.watch(recordStatusProvider) != "pausing",
      maintainState: ref.watch(recordStatusProvider) != "pausing",
      maintainAnimation: ref.watch(recordStatusProvider) != "pausing",
      visible: ref.watch(recordStatusProvider) == "pending",
      child: GestureDetector(
        onTap: () async {
          if(!UserService.hasLoggedIn()) {
            showDialog(
                context: context,
                builder: (context) {
                  return LoginPageScreen();
                }
            );
            return;
          }
          final uploadMethod = await showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return UploadMethodBottomModel();
            }
          );
          if(uploadMethod == "device") {
            if(context.mounted) {
              uploadFromDevice(ref, context);
            }
          } else if(uploadMethod == "rss") {
            if(context.mounted) {
              uploadFromRss(ref, context);
            }
          }
        },
        child: SizedBox(
          height: 30.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file_outlined,
                color: Colors.white,
                size: 20.w,
              ),
              AutoSizeText(
                "上傳檔案",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white
                ),
              )
            ],
          ),
        )
      )
    );
  }
}