import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/dto/transition_dto.dart';
import 'package:flutter_riverpod/legacy.dart';

final transitionListProvider = StateProvider<List<TransitionDto>?>((ref) => null);
final transitionLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final transitionPlayerIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final transitionSelectedProvider = StateProvider<TransitionDto?>((ref) => null);
final transitionPlayerStatusProvider = StateProvider.autoDispose<PlayerStatus>((ref) => PlayerStatus.stop);
enum PlayerStatus {
  playing,
  loading,
  stop
}