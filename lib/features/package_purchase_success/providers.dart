import 'package:actpod_web/dto/package_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packagePurchaseSuccessProvider =
    StateProvider.autoDispose<PackageInfoWithStoriesItem?>((ref) => null);
final packagePurchaseSuccessLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final packagePurchaseSuccessErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);
