import 'dart:async';
import 'dart:io';
import 'package:quick_share_app/services/permission_service.dart';
import 'package:record/record.dart';

class RecordService {
  final AudioRecorder _recorderController;
  String? path;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  double minVolume = -50.0;
  double _lastAmplitude = 0.0;
  List<double> _waveformData = [];
  StreamSubscription<RecordState>? recordStateStream;
  RecordState _recordState = RecordState.stop;

  RecordService(this._recorderController);

  Future<bool> checkPermission() async {
    return await PermissionService.askRecorderPermission();
  }

  Future<void> startRecording(String path, Function onDurationChanged) async {
    this.path = path;
    await _recorderController.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, // Ensure AAC is used for .wav
        sampleRate: 44100,        // Typical sample rate for high-quality audio
        bitRate: 128000,          // Typical bitrate for AAC
      ),
      path: path,
    );
    recordStateStream = _recorderController.onStateChanged().listen((recordState) {
      _recordState = recordState;
    });
    _timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) async {
        if(await _recorderController.isRecording()) {
          _currentDuration = _currentDuration + const Duration(milliseconds: 50);
          Amplitude amp = await _recorderController.getAmplitude();
          // Apply noise filtering
          if (amp.current < minVolume) {
            _lastAmplitude = 0.01; // Ignore amplitudes below the threshold
          } else {
            _lastAmplitude = (amp.current - minVolume) / minVolume;
            _lastAmplitude = _lastAmplitude > 1? 0.0 : _lastAmplitude;
          }
          _lastAmplitude = _lastAmplitude * 0.6; // Scale amplitude down by 20%
          _waveformData.add(_lastAmplitude);
          onDurationChanged(_currentDuration);
        }
    });
  }

  List<double> getWaveData() {
    return [..._waveformData];
  }

  double getLastWaveData() {
    return _lastAmplitude;
  }

  Future<String?> stopRecording() async {
    String? path = await _recorderController.stop();
    _timer?.cancel();
    _timer = null;
    return path;
  }

  Future<void> resetRecording(bool clear) async {
    if(clear && path != null) {
      File(path!).delete();
    }
    path = null;
    _currentDuration = Duration.zero;
    _lastAmplitude = 0.0;
    _waveformData = [];
    _timer?.cancel();
    _timer = null;
    if(_recordState != RecordState.stop) {
      _recorderController.stop();
    }
  }

  Future<void> pauseRecording() async {
    await _recorderController.pause();
    _timer?.cancel();
    _timer = null;
  }

  Future<void> resumeRecording(Function onDurationChanged) async {
    await _recorderController.resume();
    _timer ??= Timer.periodic(
      const Duration(milliseconds: 50), (timer) async {
      if(await _recorderController.isRecording()) {
        _currentDuration = _currentDuration + const Duration(milliseconds: 50);
        Amplitude amp = await _recorderController.getAmplitude();
        // Apply noise filtering
        if (amp.current < minVolume) {
          _lastAmplitude = 0.01; // Ignore amplitudes below the threshold
        } else {
          _lastAmplitude = (amp.current - minVolume) / minVolume;
          _lastAmplitude = _lastAmplitude > 1? 0.0 : _lastAmplitude;
        }
        _lastAmplitude = _lastAmplitude * 0.6; // Scale amplitude down by 20%
        _waveformData.add(_lastAmplitude);
        onDurationChanged(_currentDuration);
      }
    });
  }

  Duration getRecordedDuration() {
    return _currentDuration;
  }

  void dispose() {
    _recorderController.stop();
    _timer?.cancel();
    _timer = null;
  }
}