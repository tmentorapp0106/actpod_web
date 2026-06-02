import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_share_app/shared_prefs/record_backup_prefs.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'package:uuid/uuid.dart';

import '../../../services/record_service.dart';

class RecordController {
  WidgetRef ref;
  String audioFilePath = "";
  List<double> waveformData = [];
  RecordService recordService;
  Duration currentRecordTime = Duration.zero;
  int _waveIndex = 0;
  StreamSubscription<double>? progressSub;
  final Duration durationConstraint = const Duration(minutes: 2);
  final extractionController = WaveformExtractionController();

  RecordController(this.recordService, this.ref);

  Future<void> startRecord() async {
    if(!(await recordService.checkPermission())) {
      return;
    }

    Directory appDirectory = await getTemporaryDirectory();
    final recordFolder = Directory('${appDirectory.path}/record'); // Specify folder name
    if (!(await recordFolder.exists())) {
      await recordFolder.create(recursive: true);  // Create the folder
    }

    String path = "${appDirectory.path}/record/${Uuid().v1()}.wav";

    await recordService.startRecording(
        path,
        (duration) {
          currentRecordTime = duration;
          ref.watch(recordTimerProvider.notifier).state = duration;
          updateWaveData(recordService.getLastWaveData());
        }
    );
    ref.watch(recordStatusProvider.notifier).state = "recording";
  }

  Future<void> updateWaveData(double data) async {
    List<double> waveData = ref.watch(waveformDataProvider);
    if(_waveIndex % 2 == 0) {
      waveData.removeAt(0);
      waveData.add(data);
      ref.watch(waveformDataProvider.notifier).state = [...waveData];
    }
    _waveIndex++;
  }

  Future<void> pauseRecord() async {
    await recordService.pauseRecording();
    ref.watch(recordStatusProvider.notifier).state = "pausing";
  }

  Future<void> resumeRecording() async {
    await recordService.resumeRecording(
        (duration) {
          currentRecordTime = duration;
          ref.watch(recordTimerProvider.notifier).state = duration;
          updateWaveData(recordService.getLastWaveData());
        }
    );
    ref.watch(recordStatusProvider.notifier).state = "recording";
  }

  Future<void> stopRecord() async {
    _waveIndex = 0;
    await recordService.pauseRecording();
    waveformData = recordService.getWaveData().asMap() // 縮短總長度，3個只取一個
        .entries
        .where((entry) => entry.key % 3 == 0)
        .map((entry) => entry.value)
        .toList();
    String? path = await recordService.stopRecording();
    await RecordBackupPrefs.setBackupPath(path!);
    await RecordBackupPrefs.setBackupWaveformData(waveformData);
    await RecordBackupPrefs.setBackupLength(currentRecordTime.inMilliseconds);
    audioFilePath = path;
    ref.watch(waveformDataProvider.notifier).state = List.generate(100, (index) => 0.0);
  }

  Future<void> stopTestRecord() async {
    _waveIndex = 0;
    ref.watch(waveformDataProvider.notifier).state = List.generate(100, (index) => 0.0);
    await recordService.pauseRecording();
    String? path = await recordService.stopRecording();
    audioFilePath = path!;
    ref.watch(recordStatusProvider.notifier).state = "pending";
    return;
  }

  Future<List<double>> getAudioWaveform(String filePath) async {
    Duration? length = await AudioUtils.getAudioFileLength(filePath);
    progressSub = extractionController.onExtractionProgress.listen((progress) {
      print("Extraction Progress: ${progress.toStringAsFixed(1)}%");
    });

    final waveformData = await extractionController.extractWaveformData(
      path: filePath,
      noOfSamples: length!.inSeconds * 10,
    );

    ref.watch(recordStatusProvider.notifier).state = "pending";
    return waveformData;
  }

  Future<void> resetRecording({bool clear = false}) async {
    _waveIndex = 0;
    ref.watch(recordStatusProvider.notifier).state = "pending";
    ref.watch(recordTimerProvider.notifier).state = Duration.zero;
    ref.watch(waveformDataProvider.notifier).state = List.generate(100, (index) => 0.0);
    await recordService.resetRecording(clear);
  }

  bool checkDurationConstraint() {
    return true;
  }

  void dispose() {
    progressSub?.cancel();
    progressSub = null;
  }
}