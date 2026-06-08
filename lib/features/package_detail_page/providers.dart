import 'package:actpod_web/dto/package_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packageDetailProvider =
    StateProvider.autoDispose<PackageInfoWithStoriesItem?>((ref) => null);
final packageDetailLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final packageDetailErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);
