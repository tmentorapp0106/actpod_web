import 'package:firebase_remote_config/firebase_remote_config.dart';

class PackagePurchaseCountService {
  static const String _countKeyPrefix = "package_purchase_count_";

  Future<int> getPurchaseCount(String packageId) async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 6),
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      return _readActivatedCount(remoteConfig, packageId);
    }

    return _readActivatedCount(remoteConfig, packageId);
  }

  int _readActivatedCount(
    FirebaseRemoteConfig remoteConfig,
    String packageId,
  ) {
    final packageKey = "$_countKeyPrefix$packageId";

    return _toInt(remoteConfig.getValue(packageKey).asString());
  }

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}
