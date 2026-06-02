import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/features/space_story_feature/components/stories_wall.dart';
import 'package:quick_share_app/features/space_story_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

import '../../config/color.dart';
import '../../dto/space_dto.dart';
import 'controllers/space_story_controller.dart';

class SpaceStoryScreen extends ConsumerStatefulWidget {
  final SpaceInfoDto spaceInfo;

  SpaceStoryScreen(this.spaceInfo);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return BoardStoryScreenState();
  }
}

class BoardStoryScreenState extends ConsumerState<SpaceStoryScreen> with RouteAware {
  SpaceStoryController? boardStoryController;

  @override
  void initState() {
    super.initState();
    boardStoryController = SpaceStoryController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initProviders();
      await boardStoryController!.getSpaceStories(widget.spaceInfo.spaceId);
      previewPlayerController.reset(ref, PreviewPage.space);
    });
  }

  void initProviders() {
    ref.watch(spaceStoriesProvider.notifier).state = [];
  }

  @override
  void dispose() {
    previewPlayerController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    previewPlayerController.stop(ref, force: true);
  }

  @override
  void didPopNext() {
  }
  
  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.network(
                widget.spaceInfo.imageUrl,
                width: 24.w,
                height: 24.w,
              ),
              const SizedBox(width: 4,),
              Text(
                widget.spaceInfo.name,
                style: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 24.w
                ),
              ),
            ]
          ),
          centerTitle: true,
          backgroundColor: ConfigColor.background,
          elevation: 0
        ),
        backgroundColor: ConfigColor.background,
        body: SafeArea(
          child: NestedScrollView(
            physics: BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar( // for visibility detector: if has this, detector will only attach the latest widget on the screen. without this detector will attach the latest widget(outside the screen)
                  toolbarHeight: 0.h,
                  collapsedHeight: 0.h,
                  backgroundColor: ConfigColor.background,
                ),
              ];
            },
            body: Column(
              children: [
                Expanded(
                  child: StoriesWall(boardStoryController!)
                ),
                SizedBox(height: 70.h,)
              ],
            ),
          )
        )
      )
    );
  }
}