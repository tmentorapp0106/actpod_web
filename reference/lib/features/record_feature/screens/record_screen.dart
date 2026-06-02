import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/components/whole_page_progress.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/components/policy_agreement_dialog.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/record_feature/components/backup_dialog.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/continue_record_text.dart';
import 'package:quick_share_app/features/record_feature/components/record_screen/upload_button.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_controller.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';
import 'package:quick_share_app/features/record_feature/services/permission_service.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/cache_service.dart';
import 'package:quick_share_app/services/record_service.dart';
import 'package:quick_share_app/shared_prefs/agreement_prefs.dart';
import 'package:quick_share_app/shared_prefs/record_backup_prefs.dart';
import 'package:quick_share_app/utils/screen_utils.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../services/toast_service.dart';
import '../../../utils/audio_utils.dart';
import '../../edit_and_upload_story_feature/edit_and_upload_story_screen.dart';
import '../components/record_screen/record_button_set.dart';
import '../components/record_screen/record_status_text.dart';
import '../components/record_screen/record_timer.dart';
import '../components/record_screen/record_title.dart';
import '../components/record_screen/record_wave.dart';
import '../components/record_screen/upload_file_button.dart';
import '../controllers/recorder_controller.dart';
import '../providers/providers.dart';

class RecordScreen extends ConsumerStatefulWidget {

  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() {
    return RecordScreenState();
  }
}

class RecordScreenState extends ConsumerState<RecordScreen> {
  RecordController? recordController;
  FeedController? feedController;
  bool _grantedRecordPermission = false;
  AudioRecorder recorderController = AudioRecorder();
  RecordService? recordService;

  RecordScreenState();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    recordService  = RecordService(recorderController);
    recordController = RecordController(recordService!, ref);
    feedController = FeedController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CacheService.cleanAudioCache();
      initProviders();
      checkAgreement();
      checkBackup();
    });
  }

  void checkAgreement() {
    if(AgreementPrefs.getContentPolicyAgreement() == null || AgreementPrefs.getContentPolicyAgreement() == false) {
      showDialog(
        context: context,
        builder: (context) {
          return PolicytAgreementDialog();
        }
      );
    }
  }

  Future<void> checkBackup() async {
    if(RecordBackupPrefs.getBackupPath() == null || RecordBackupPrefs.getBackupPath() == "") {
      return;
    }
    bool use = await showDialog(
      context: context,
      builder: (context) {
        return BackupDialog();
      }
    );
    if(use) {
      processNormalization();
    }
  }

  void processNormalization() {
    int wavProgress = 0;
    int m4aProgress = 0;
    String? wavFilePath;
    String? m4aFilePath;

    String? audioFilePath = RecordBackupPrefs.getBackupPath();
    if(audioFilePath == null) {
      return;
    }
    ref.watch(loadingProvider.notifier).state = true;

    void onProgressChange() {
      ref.watch(loadingPercentageProvider.notifier).state = ((wavProgress + m4aProgress) / 2).toInt();
    }

    Future<void> onProcessComplete() async {
      if(wavFilePath != null && m4aFilePath != null && context.mounted) {
        await recordController!.resetRecording(clear: false);
        ref.watch(loadingTextProvider.notifier).state = null;
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
        if(!context.mounted) {
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return RecordPreviewScreen(
            false, 
            originWavFilePath: audioFilePath, 
            normalizedM4aFilePath: m4aFilePath,
            normalizedWavFilePath: wavFilePath, 
            waveformData: RecordBackupPrefs.getBackupWaveformData()
          );
        }));
      }
    }

    AudioUtils.normalizeAudio(
      audioFilePath,
      "wav",
      (filePath) async {
        wavFilePath = filePath;
        onProcessComplete();
      },
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        ref.watch(loadingTextProvider.notifier).state = null;
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
      },
      (progress) {
        wavProgress = (progress / RecordBackupPrefs.getBackupLength() * 100).toInt();
        onProgressChange();
      },
      false
    );
    AudioUtils.normalizeAudio(
      audioFilePath,
      "m4a",
      (filePath) async {
        m4aFilePath = filePath;
        onProcessComplete();
      },
      () {
        ToastService.showNoticeToast("音檔處理失敗");
        ref.watch(loadingProvider.notifier).state = false;
        ref.watch(loadingPercentageProvider.notifier).state = null;
      },
      (progress) {
        m4aProgress = (progress / RecordBackupPrefs.getBackupLength() * 100).toInt();
        onProgressChange();
      },
      false,
    );
  }

  void initProviders() {
    ref.watch(loadingProvider.notifier).state = false;
    ref.watch(loadingPercentageProvider.notifier).state = null;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    WakelockPlus.disable();
    await CacheService.cleanAudioCache();
    recordController!.dispose();
    recordService!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFFEABB),
                Color(0xFFFFEFC7),
              ],
              stops: [
                0, 0.3, 1
              ]
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: ref.watch(recordStatusProvider) == "pending"? Colors.black : DesignSystem.borderGrey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: RecordStatusText(),
            centerTitle: true,
            backgroundColor: ref.watch(recordStatusProvider) == "pending"? Colors.transparent : Colors.black,
            elevation: 0
          ),
          backgroundColor: ref.watch(recordStatusProvider) == "pending"? Colors.transparent : Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 60.h,),
                RecordTitle(),
                RecordWave(recorderController),
                UploadButton(feedController!),
                SizedBox(height: 20.h,),
              ],
            )
          )
        ),
        WholePageProgress(
          showProvider: loadingProvider,
          percentageProvider: loadingPercentageProvider,
          textColor: Colors.white,
          child: const SizedBox.shrink(),
        )
      ]
    );
  }
}