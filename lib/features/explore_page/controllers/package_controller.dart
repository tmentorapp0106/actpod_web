import 'package:actpod_web/api_manager/story_api_manager.dart';
import 'package:actpod_web/api_manager/story_dto/get_packages_res.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PackageController {
  WidgetRef ref;

  PackageController(this.ref);

  Future<void> getPackages() async {
    GetPackagesRes response = await storyApiManager.getPackages();
    print(response);
    if(response.code != "0000") {
      return;
    }
    ref.watch(packagesProvider.notifier).state = response.packages;
  }
}