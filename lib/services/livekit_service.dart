import 'dart:async';
import 'dart:io';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  Room? _room;

  LocalAudioTrack? _micTrack;
  LocalTrackPublication<LocalAudioTrack>? _micPub;

  final _lock = Lock();

  final StreamController<ConnectionState> _connectionStateController =
  StreamController<ConnectionState>.broadcast();

  Stream<ConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  ConnectionState get currentConnectionState =>
      _room?.connectionState ?? ConnectionState.disconnected;

  final Map<String, bool> _speakingMap = {};

  final StreamController<Map<String, bool>> _speakingMapController =
  StreamController<Map<String, bool>>.broadcast();

  Stream<Map<String, bool>> get speakingMapStream =>
      _speakingMapController.stream;

  Map<String, bool> get currentSpeakingMap =>
      Map<String, bool>.from(_speakingMap);

  bool isParticipantSpeaking(String identity) =>
      _speakingMap[identity] ?? false;

  EventsListener<RoomEvent>? _roomEventsListener;

  Future<void> joinAsListener({
    required String url,
    required String token,
  }) async {
    await leave();

    _emitConnectionState(ConnectionState.connecting);

    const roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultAudioCaptureOptions: AudioCaptureOptions(
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
        voiceIsolation: true,
        stopAudioCaptureOnMute: true,
      ),
    );

    final r = Room(roomOptions: roomOptions);

    try {
      await r.connect(url, token);

      _room = r;
      r.addListener(_onRoomChanged);

      _roomEventsListener = r.createListener();

      // Source of truth: active speakers from Room
      _roomEventsListener!.on<ActiveSpeakersChangedEvent>((event) {
        _rebuildSpeakingMapFromRoom(r);
      });

      _roomEventsListener!.on<ParticipantConnectedEvent>((event) {
        _speakingMap.putIfAbsent(event.participant.identity, () => false);
        _emitSpeakingMap();
      });

      _roomEventsListener!.on<ParticipantDisconnectedEvent>((event) {
        _speakingMap.remove(event.participant.identity);
        _emitSpeakingMap();
      });

      _seedSpeakingState(r);

      _emitConnectionState(r.connectionState);
      _emitSpeakingMap();
    } catch (e) {
      _emitConnectionState(ConnectionState.disconnected);
      rethrow;
    }
  }

  void _seedSpeakingState(Room r) {
    _speakingMap.clear();
    _rebuildSpeakingMapFromRoom(r, emit: false);
  }

  void _rebuildSpeakingMapFromRoom(Room r, {bool emit = true}) {
    final nextSpeakingIds = r.activeSpeakers.map((p) => p.identity).toSet();

    final nextMap = <String, bool>{};

    final lp = r.localParticipant;
    if(lp != null) {
      nextMap[lp.identity] = nextSpeakingIds.contains(lp.identity);
    }

    for (final p in r.remoteParticipants.values) {
      nextMap[p.identity] = nextSpeakingIds.contains(p.identity);
    }

    _speakingMap
      ..clear()
      ..addAll(nextMap);

    if (emit) {
      _emitSpeakingMap();
    }
  }

  void _emitSpeakingMap() {
    if (!_speakingMapController.isClosed) {
      _speakingMapController.add(Map<String, bool>.from(_speakingMap));
    }
  }

  Future<void> startTalking() async {
    if(_micPub != null) {
      await _lock.synchronized(() async {
        await _micPub?.unmute();
      });
    } else {
      await _lock.synchronized(() async {
        final r = _room;
        final lp = r?.localParticipant;
        if (r == null || lp == null) return;
        if (r.connectionState != ConnectionState.connected) return;
        if (_micPub != null) return;

        _micTrack = await LocalAudioTrack.create();
        _micPub = await lp.publishAudioTrack(_micTrack!);
      });
    }
  }

  Future<void> stopTalking() async {
    if(Platform.isIOS) {
      await _lock.synchronized(() async {
        await _micPub?.mute();
      });
    } else {
      await _lock.synchronized(() async {
        final r = _room;
        final lp = r?.localParticipant;
        final pub = _micPub;
        final track = _micTrack;

        if (r == null || lp == null) return;

        try {
          if (pub?.track != null) {
            await lp.removePublishedTrack(_micTrack!.sid!);
          }
        } catch (_) {}

        try {
          await track?.stop();
        } catch (_) {}

        _micPub?.dispose();
        _micPub = null;
        _micTrack = null;
      });
    }
  }

  double _normalizeVolume(double volume) {
    if (volume < 0) return 0;
    if (volume > 1) return 1;
    return double.parse(volume.toStringAsFixed(1));
  }

  /// Set volume for all audio tracks of one remote participant.
  /// [identity] = participant identity, for example: "bgm-bot-123"
  Future<void> setParticipantAudioVolume({
    required String identity,
    required double volume,
  }) async {
    final r = _room;
    if (r == null) return;

    final targetVolume = _normalizeVolume(volume);

    RemoteParticipant? participant;
    try {
      participant = r.remoteParticipants.values.firstWhere(
            (p) => p.identity == identity,
      );
    } catch (_) {
      return;
    }

    for (final pub in participant.trackPublications.values) {
      final track = pub.track;
      if (track is RemoteAudioTrack) {
        Helper.setVolume(targetVolume, track.mediaStreamTrack);
      }
    }
  }

  void _onRoomChanged() {
    final r = _room;
    if (r == null) return;

    _emitConnectionState(r.connectionState);

    if (r.connectionState == ConnectionState.disconnected) {
      _micPub?.dispose();
      _micPub = null;
      _micTrack = null;
      _speakingMap.clear();
      _emitSpeakingMap();
    }
  }

  void _emitConnectionState(ConnectionState state) {
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  Future<void> leave() async {
    await _lock.synchronized(() async {
      final r = _room;
      if (r == null) {
        _emitConnectionState(ConnectionState.disconnected);
        _speakingMap.clear();
        _emitSpeakingMap();
        return;
      }

      r.removeListener(_onRoomChanged);
      await _roomEventsListener?.dispose();
      _roomEventsListener = null;

      try {
        await _micTrack?.stop();
      } catch (_) {}

      _micPub?.dispose();
      _micPub = null;
      _micTrack = null;

      await r.disconnect();
      _room = null;

      _speakingMap.clear();

      _emitConnectionState(ConnectionState.disconnected);
      _emitSpeakingMap();
    });
  }

  Future<void> dispose() async {
    await leave();
    await _connectionStateController.close();
    await _speakingMapController.close();
  }
}