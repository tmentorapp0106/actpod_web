import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/services/package_purchase_count_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packageDetailProvider =
    StateProvider.autoDispose<PackageInfoWithStoriesItem?>((ref) => null);
final packageDetailLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final packageDetailErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final packagePurchasedProvider =
    StateProvider.autoDispose<bool?>((ref) => null);
final packagePurchaseCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, packageId) {
  return PackagePurchaseCountService().getPurchaseCount(packageId);
});
