import 'package:flutter_riverpod/legacy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final sendVoiceMessageStatusProvider = StateProvider<String>((ref) => "pending"); // pending, recording, recorded, playing, paused, uploading
final voiceMessageLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final messageRecordTimerProvider = StateProvider<Duration>((ref) => Duration.zero);
final messagePlayingTimerProvider = StateProvider<Duration>((ref) => Duration.zero);
final donateAmountProvider = StateProvider<int>((ref) => 0);
final purchaseAmountProvider = StateProvider<int>((ref) => 0);
final isPurchasingProvider = StateProvider<bool>((ref) => false);
final isSelectingDonationProvider = StateProvider<bool>((ref) => false);
final changeVoiceProvider = StateProvider<bool>((ref) => false);
final acceptAddProvider = StateProvider<bool>((ref) => true);