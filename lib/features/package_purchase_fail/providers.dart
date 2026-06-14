import 'package:actpod_web/dto/package_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packagePurchaseFailProvider =
    StateProvider.autoDispose<PackageInfoWithStoriesItem?>((ref) => null);
final packagePurchaseFailLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final packagePurchaseFailErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);
