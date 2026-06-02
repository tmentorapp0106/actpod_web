import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/live_api_dto/exist_ticket.dart';
import 'package:quick_share_app/apiManagers/live_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/purchase_live_room_ticket_res.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/live_feature/components/ticket_dialog.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/features/live_feature/screens/live_room_schedule.dart';
import 'package:quick_share_app/providers.dart';

import '../../../apiManagers/live_api_dto/get_price_rule.dart';
import '../../../config/color.dart';
import '../../../dto/live_room_dto.dart';
import '../../../router.dart';
import '../../../services/toast_service.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../components/live_room_card.dart';
import '../controllers/live_controller.dart';
import '../dto/purchase_ticket_enum.dart';

class LiveRoomsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VoiceMessageNoticePageScreenState();
  }
}

class VoiceMessageNoticePageScreenState extends ConsumerState<LiveRoomsScreen> {
  LiveController? liveController;

  @override
  void initState() {
    super.initState();
    liveController = LiveController(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      liveController!.getLiveRooms();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<LiveRoomDto>? rooms = ref.watch(activeRoomsProvider);

    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.w,
          title: Text(
            '陪聽互動房',
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold,
              color: ConfigColor.textColorDefault,
            ),
          ),
          centerTitle: true,
          backgroundColor: ConfigColor.background,
          surfaceTintColor: ConfigColor.background,
          elevation: 0,
          actions: [
            IconButton(
            padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LiveRoomSchedule(),
                ));
              },
              icon: Icon(
                Icons.calendar_month_rounded,
                color: DesignColor.actpodPrimary400,
                size: 28.w
              )
            )
          ],
        ),
        backgroundColor: ConfigColor.background,
        body: SafeArea(
          child: _buildBody(rooms),
        ),
      )
    );
  }

  Widget _buildBody(List<dynamic>? rooms) {
    return RefreshIndicator(
      color: DesignColor.actpodPrimary400,
      onRefresh: () async {
        await liveController!.getLiveRooms();
      },
      child: _buildRefreshContent(rooms),
    );
  }

  Widget _buildRefreshContent(List<dynamic>? rooms) {
    if (rooms == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: CircularProgressIndicator(
                color: DesignColor.actpodPrimary400,
              ),
            ),
          ),
        ],
      );
    }

    if (rooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/frustrated.png",
                    width: 220.w,
                    height: 220.w,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "目前沒有互動房",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "晚點再回來看看吧",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: rooms.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == rooms.length) {
          return SizedBox(height: 80.h);
        }

        LiveRoomDto room = rooms[index];
        return SizedBox(
          width: double.infinity,
          child: LiveRoomCard(
            imageUrl: room.storyImages.isNotEmpty ? room.storyImages[0] : null,
            title: room.title,
            channelName: room.channelName,
            channelImageUrl: room.channelImageUrl,
            count: room.memberCount,
            roomType: room.roomType,
            onTap: () async {
              if (!UserService.hasLoggedIn()) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return LoginPageScreen();
                  },
                );
                return;
              }

              // if (UserService.getUserInfo()!.userId == room.hostId) {
              //   ToastService.showNoticeToast("無法進入自己開的房間");
              //   return;
              // }

              if (!room.allowEnter) {
                ToastService.showNoticeToast("此房間已無法進入");
                return;
              }

              if (room.roomType == "interactive") {
                if(room.hostId == UserService.getUserInfo()!.userId) {
                  await router.push(
                    "/live/interactive/host/${room.storyId}",
                    extra: {
                      "roomId": room.roomId,
                      "title": room.title.trim(),
                      "notifyFans": false,
                      "capacity": 0,
                      "notyetOwnedStoryPrice": 0,
                      "alreadyOwnedStoryPrice": 0
                    },
                  );
                } else {
                  final result = await router.push(
                    "/live/interactive/audience/${room.roomId}/${room.storyId}",
                  );
                  if (result != null && result == PurchaseTicketEnum.notEnough) {
                    router.push("/purchase");
                  }
                }
              } else {
                if(room.hostId == UserService.getUserInfo()!.userId) {
                  await router.push(
                    "/live/listen_together/host/${room.storyId}",
                    extra: {
                      "roomId": room.roomId,
                      "title": room.title.trim(),
                      "notifyFans": false,
                      "notyetOwnedStoryPrice": 0,
                      "alreadyOwnedStoryPrice": 0
                    },
                  );
                } else {
                  final result = await router.push(
                    "/live/listen_together/audience/${room.roomId}/${room.storyId}",
                  );
                  if (result != null && result == PurchaseTicketEnum.notEnough) {
                    router.push("/purchase");
                  }
                }
              }

              await liveController!.getLiveRooms();
            },
          ),
        );
      },
    );
  }
}