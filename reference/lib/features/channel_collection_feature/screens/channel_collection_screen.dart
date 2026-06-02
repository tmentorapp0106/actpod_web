import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_collection_feature/components/story_list.dart';
import 'package:quick_share_app/features/channel_collection_feature/controllers/collection_controller.dart';

import '../../../components/back_button.dart';
import '../components/empty_story.dart';
import '../components/horizontal_collection_list.dart';

class ChannelCollectionScreen extends ConsumerStatefulWidget {

  ChannelCollectionScreen();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChannelCollectionScreenState();
  }
}

class ChannelCollectionScreenState extends ConsumerState<ChannelCollectionScreen> {
  CollectionController? collectionController;

  @override
  void initState() {
    super.initState();
    collectionController = CollectionController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      collectionController!.getCollections();
      collectionController!.getCollectionStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(
            "我的收藏",
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          leading: ActPodBackButton(),  // Back button
          backgroundColor: Colors.white
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HorizontalCollectionList(),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(right: 12.w, left: 12.w),
              child: Text(
                "最新故事",
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          EmptyStory(),
          StoryList(),
        ],
      )
    );
  }
}