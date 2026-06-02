import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/space_selection_feature/components/space_item.dart';
import 'package:quick_share_app/features/space_selection_feature/controllers/space_controller.dart';
import 'package:quick_share_app/features/space_selection_feature/providers.dart';

import '../../services/page_router_service.dart';
import '../home_page_feature/providers.dart';
import '../space_story_feature/providers.dart';
import '../space_story_feature/space_story_screen.dart';

class SpaceSelectionScreen extends ConsumerStatefulWidget {

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SpaceSelectionScreenState();
  }
}

class SpaceSelectionScreenState extends ConsumerState<SpaceSelectionScreen> {
  SpaceController? spaceController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      spaceController = SpaceController(ref);
      spaceController?.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ref.watch(spaceStoriesProvider.notifier).state = [];
        // if(ref.watch(homePageStateProvider.notifier).state == "space") {
        //   PageRouterService.spaceStoryPageToHomePage(ref);
        //   return false;
        // } else if(ref.watch(spaceSelectionPageStateProvider.notifier).state == "space") {
        //   PageRouterService.spaceStoryPageToSelectionPage(ref);
        //   return false;
        // }
        return true;
      },
      child: Scaffold(
        backgroundColor: ConfigColor.background,
        body: page()
      )
    );
  }

  Widget page() {
    if(ref.watch(spaceSelectionPageStateProvider) == "selecting") {
      final spaces = ref.watch(spacesProvider);
      return SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "空間",
                  style: TextStyle(
                    color: ConfigColor.textColorDefault,
                    fontSize: 24.w,
                    fontWeight: FontWeight.bold
                  ),
                )
              ]
            ),
            SizedBox(height: 10.h,),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 70.w / 70.w,
                      crossAxisCount: 2, // Number of columns in the grid
                      crossAxisSpacing: 25.w, // Spacing between columns
                      mainAxisSpacing: 20.w, // Spacing between rows
                    ),
                    itemCount: spaces.length,
                    itemBuilder: (context, index) {
                      return SpaceItem(spaces[index]);
                    }
                )
              )
            ),
            SizedBox(height: 70.h,),
          ]
        )
      );
    } else {
      return SpaceStoryScreen(ref.watch(spaceSelectionPageSelectedSpaceInfoProvider)!);
    }
  }
}