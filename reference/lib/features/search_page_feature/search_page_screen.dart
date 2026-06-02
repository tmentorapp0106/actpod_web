import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/search_page_feature/components/search_result_list.dart';
import 'package:quick_share_app/features/search_page_feature/components/space_grid_view.dart';
import 'package:quick_share_app/features/search_page_feature/controllers/preview_play_controller.dart';
import 'package:quick_share_app/features/search_page_feature/controllers/space_controller.dart';
import 'package:quick_share_app/features/search_page_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

import '../../components/whole_page_loading.dart';
import 'components/search_bar.dart';
import 'components/title.dart';
import 'controllers/search_controller.dart';

class SearchPageScreen extends ConsumerStatefulWidget {
  SearchPageScreen();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SearchPageScreenState();
  }
}

class SearchPageScreenState extends ConsumerState<SearchPageScreen> {
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  SearchItemController? searchStoriesController;
  PreviewPlayController? previewPlayController;
  SpaceController? spaceController;

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchTextController.dispose();
    previewPlayController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchStoriesController = SearchItemController(ref);
    previewPlayController = PreviewPlayController(ref);
    spaceController = SpaceController(ref);
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus &&
          (ref.watch(searchStoriesItemListProvider) == null ||
              ref.watch(searchChannelItemListProvider) == null ||
              ref.watch(searchUserItemListProvider) == null)) {
        previewPlayController!.pausePreview();
        ref.watch(searchStoriesItemListProvider.notifier).state = [];
        ref.watch(searchUserItemListProvider.notifier).state = [];
        ref.watch(searchChannelItemListProvider.notifier).state = [];
      }
      if (!searchFocusNode.hasFocus && ref.watch(searchTextProvider) == "") {
        // ref.watch(searchStoriesItemListProvider.notifier).state = [];
      }
      ref.watch(isTextingProvider.notifier).state = searchFocusNode.hasFocus;
    });
    searchTextController.addListener(() {
      final q = searchTextController.text;
      ref.watch(searchTextProvider.notifier).state = q;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      previewPlayController!.init();
      spaceController!.getSpaces();
      ref.watch(searchStoriesItemListProvider.notifier).state = null;
      ref.watch(searchUserItemListProvider.notifier).state = null;
      ref.watch(searchChannelItemListProvider.notifier).state = null;
      ref.watch(searchPreviewIndexProvider.notifier).state = null;
      ref.watch(searchPreviewPlayStatusProvider.notifier).state = "paused";
      ref.watch(loadingProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WholePageLoading(
      provider: loadingProvider,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus(); // Unfocus the keyboard
          },
          child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPersistentHeader(
                      delegate: ref.watch(searchStoriesItemListProvider) ==
                                  null &&
                              ref.watch(searchUserItemListProvider) == null &&
                              ref.watch(searchChannelItemListProvider) == null
                          ? SearchBarDelegate(
                              68.h,
                              searchStoriesController!,
                              searchTextController,
                              previewPlayController!,
                              searchFocusNode)
                          : SearchBarDelegate(
                              108.h,
                              searchStoriesController!,
                              searchTextController,
                              previewPlayController!,
                              searchFocusNode),
                      floating: true,
                      pinned: true,
                    ),
                    PageTitle(),
                    ref.watch(searchStoriesItemListProvider) == null &&
                            ref.watch(searchUserItemListProvider) == null &&
                            ref.watch(searchChannelItemListProvider) == null
                        ? SpaceGridView()
                        : SearchResultList(previewPlayController!,searchTextController),
                    SliverToBoxAdapter(
                        child: SizedBox(
                      height: 70.h,
                    ))
                  ],
                ),
              ))));
  }
}
